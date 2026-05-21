#ifndef MAX_SEARCH_RESULTS
#define MAX_SEARCH_RESULTS 4U
#endif

typedef struct {
    uint32_t count;
    struct {
        // One word for gid and 8 for mix hash
        uint32_t gid;
        uint32_t mix[8];
    } result[MAX_SEARCH_RESULTS];
} Search_results;

typedef struct
{
    uint32_t uint32s[32 / sizeof(uint32_t)];
} hash32_t;

// Implementation based on:
// https://github.com/mjosaarinen/tiny_sha3/blob/master/sha3.c


__device__ __constant__ const uint32_t keccakf_rndc[24] = {
    0x00000001, 0x00008082, 0x0000808a, 0x80008000, 0x0000808b, 0x80000001,
    0x80008081, 0x00008009, 0x0000008a, 0x00000088, 0x80008009, 0x8000000a,
    0x8000808b, 0x0000008b, 0x00008089, 0x00008003, 0x00008002, 0x00000080,
    0x0000800a, 0x8000000a, 0x80008081, 0x00008080, 0x80000001, 0x80008008
};

// Implementation of the permutation Keccakf with width 800.
__device__ __forceinline__ void keccak_f800_round(uint32_t st[25], const int r)
{

    const uint32_t keccakf_rotc[24] = {
        1,  3,  6,  10, 15, 21, 28, 36, 45, 55, 2,  14,
        27, 41, 56, 8,  25, 43, 62, 18, 39, 61, 20, 44
    };
    const uint32_t keccakf_piln[24] = {
        10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4,
        15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1
    };

    uint32_t t, bc[5];
    // Theta
    for (int i = 0; i < 5; i++)
        bc[i] = st[i] ^ st[i + 5] ^ st[i + 10] ^ st[i + 15] ^ st[i + 20];

    for (int i = 0; i < 5; i++) {
        t = bc[(i + 4) % 5] ^ ROTL32(bc[(i + 1) % 5], 1);
        for (uint32_t j = 0; j < 25; j += 5)
            st[j + i] ^= t;
    }

    // Rho Pi
    t = st[1];
    for (int i = 0; i < 24; i++) {
        uint32_t j = keccakf_piln[i];
        bc[0] = st[j];
        st[j] = ROTL32(t, keccakf_rotc[i]);
        t = bc[0];
    }

    //  Chi
    for (uint32_t j = 0; j < 25; j += 5) {
        for (int i = 0; i < 5; i++)
            bc[i] = st[j + i];
        for (int i = 0; i < 5; i++)
            st[j + i] ^= (~bc[(i + 1) % 5]) & bc[(i + 2) % 5];
    }

    //  Iota
    st[0] ^= keccakf_rndc[r];
}

__device__ __forceinline__ uint32_t cuda_swab32(const uint32_t x)
{
    return __byte_perm(x, x, 0x0123);
}

// SHORT   seed generation (header + nonce only)
// Padding: st[10]=0x00000001, st[18]=0x80008081
// Returns all 8 seed words needed for DAG merge
__device__ __noinline__ void keccak_f800_short(
    hash32_t header, uint64_t nonce, uint32_t seed_out[8])
{
    uint32_t st[25];
    for (int i = 0; i < 25; i++)
        st[i] = 0;
    for (int i = 0; i < 8; i++)
        st[i] = header.uint32s[i];
    st[8] = (uint32_t)nonce;
    st[9] = (uint32_t)(nonce >> 32);
    st[10] = 0x00000001;
    st[18] = 0x80008081;
    for (int r = 0; r < 22; r++)
        keccak_f800_round(st, r);
    for (int i = 0; i < 8; i++)
        seed_out[i] = st[i];
}

// LONG   final hash (header + nonce + mix digest)
// Padding: st[18]=0x00000001, st[24]=0x80008081
// Returns 64-bit result compared against target
__device__ __noinline__ uint64_t keccak_f800_long(hash32_t header, uint64_t nonce, hash32_t digest)
{
    uint32_t st[25];
    for (int i = 0; i < 25; i++)
        st[i] = 0;
    for (int i = 0; i < 8; i++)
        st[i] = header.uint32s[i];
    st[8] = (uint32_t)nonce;
    st[9] = (uint32_t)(nonce >> 32);
    for (int i = 0; i < 8; i++)
        st[10 + i] = digest.uint32s[i];
    st[18] = 0x00000001;
    st[24] = 0x80008081;
    for (int r = 0; r < 22; r++)
        keccak_f800_round(st, r);
    return (uint64_t)cuda_swab32(st[0]) << 32 | cuda_swab32(st[1]);
}

#define fnv1a(h, d) (h = (uint32_t(h) ^ uint32_t(d)) * uint32_t(0x1000193))

typedef struct {
    uint32_t z, w, jsr, jcong;
} kiss99_t;

// KISS99 is simple, fast, and passes the TestU01 suite
// https://en.wikipedia.org/wiki/KISS_(algorithm)
// http://www.cse.yorku.ca/~oz/marsaglia-rng.html
__device__ __forceinline__ uint32_t kiss99(kiss99_t &st)
{
    st.z = 36969 * (st.z & 65535) + (st.z >> 16);
    st.w = 18000 * (st.w & 65535) + (st.w >> 16);
    uint32_t MWC = ((st.z << 16) + st.w);
    st.jsr ^= (st.jsr << 17);
    st.jsr ^= (st.jsr >> 13);
    st.jsr ^= (st.jsr << 5);
    st.jcong = 69069 * st.jcong + 1234567;
    return ((MWC^st.jcong) + st.jsr);
}

__device__ __forceinline__ void fill_mix(uint64_t seed, uint32_t lane_id, uint32_t mix[PROGPOW_REGS])
{
    // Use FNV to expand the per-warp seed to per-lane
    // Use KISS to expand the per-lane seed to fill mix
    uint32_t fnv_hash = 0x811c9dc5;
    kiss99_t st;
    st.z = fnv1a(fnv_hash, seed);
    st.w = fnv1a(fnv_hash, seed >> 32);
    st.jsr = fnv1a(fnv_hash, lane_id);
    st.jcong = fnv1a(fnv_hash, lane_id);
    #pragma unroll
    for (int i = 0; i < PROGPOW_REGS; i++)
        mix[i] = kiss99(st);
}

__global__ void 
progpow_search(
    uint64_t start_nonce,
    const hash32_t header,
    const uint64_t target,
    const dag_t *g_dag,
    volatile Search_results* g_output,
    bool hack_false
    )
{
    __shared__ uint32_t c_dag[PROGPOW_CACHE_WORDS];
    uint32_t const gid = blockIdx.x * blockDim.x + threadIdx.x;
    uint64_t const nonce = start_nonce + gid;

const uint32_t lane_id = threadIdx.x & (PROGPOW_LANES - 1);

    hash32_t digest;
    for (int i = 0; i < 8; i++)
        digest.uint32s[i] = 0;

    // keccak(header..nonce)
    uint32_t seed_w[8];
    keccak_f800_short(header, nonce, seed_w);

    uint64_t hash_seed = ((uint64_t)seed_w[1] << 32) | (uint64_t)seed_w[0];
    // Load L1 cache from first portion of DAG - matches chain BuildL1Cache(dag)
    for (uint32_t word = threadIdx.x * PROGPOW_DAG_LOADS; word < PROGPOW_CACHE_WORDS;
        word += blockDim.x * PROGPOW_DAG_LOADS)
    {
        dag_t load = g_dag[word / PROGPOW_DAG_LOADS];
        for (int i = 0; i < PROGPOW_DAG_LOADS; i++)
            c_dag[word + i] = load.s[i];
    }
    __syncthreads();

    #pragma unroll 1
    for (uint32_t h = 0; h < PROGPOW_LANES; h++)
    {
        uint32_t mix[PROGPOW_REGS];
        // share hash_seed across all lanes
        uint64_t lane_hash_seed = SHFL(hash_seed, h, PROGPOW_LANES);
        // initialize mix for all lanes
        fill_mix(lane_hash_seed, lane_id, mix);
        // Broadcast the 8 seed words to each lane
        uint32_t lane_seed_w[8];
        for (int s = 0; s < 8; s++)
            lane_seed_w[s] = SHFL(seed_w[s], h, PROGPOW_LANES);
#pragma unroll 1
        for (uint32_t l = 0; l < PROGPOW_CNT_DAG; l++)
            progPowLoop(l, mix, g_dag, c_dag, lane_seed_w, hack_false);


        // Reduce mix data to a per-lane 32-bit digest
        uint32_t digest_lane = 0x811c9dc5;
        #pragma unroll
        for (int i = 0; i < PROGPOW_REGS; i++)
            fnv1a(digest_lane, mix[i]);

        // Reduce all lanes to a single 256-bit digest
        hash32_t digest_temp;
        #pragma unroll
        for (int i = 0; i < 8; i++)
            digest_temp.uint32s[i] = 0x811c9dc5;

        for (int i = 0; i < PROGPOW_LANES; i += 8)
            #pragma unroll
            for (int j = 0; j < 8; j++)
                fnv1a(digest_temp.uint32s[j], SHFL(digest_lane, i + j, PROGPOW_LANES));

        if (h == lane_id)
            digest = digest_temp;
    }

    // keccak(header .. keccak(header..nonce) .. digest);
    uint64_t final_hash = keccak_f800_long(header, nonce, digest);
final_hash = __byte_perm((uint32_t)final_hash, 0, 0x0123) |
             ((uint64_t)__byte_perm((uint32_t)(final_hash >> 32), 0, 0x0123) << 32);

if (final_hash > target)
    return;

    uint32_t index = atomicInc((uint32_t *)&g_output->count, 0xffffffff);
    if (index >= MAX_SEARCH_RESULTS)
        return;

    g_output->result[index].gid = gid;
    #pragma unroll
    for (int i = 0; i < 8; i++)
        g_output->result[index].mix[i] = digest.uint32s[i];
}

