mod keccakf;
mod secp256k1;
/// Executes `KECCAK_PERMUTE`.
pub const KECCAKF: u32 = 0x00_01_01_01;
pub const SECP256K_ADD: u32 = 0x00_02_01_01;
pub const SECP256K_DOUBLE: u32 = 0x00_02_01_01;
