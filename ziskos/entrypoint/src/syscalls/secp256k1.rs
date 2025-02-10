#[cfg(target_os = "ziskos")]
use core::arch::asm;

/// Executes the `secp256k1_add` system call, which adds the Secp256k1 points `p` and `q`
/// and updates `p` with the result.
///
/// - The `SECP256K_ADD` constant is written to the A7 register.
/// - The `p` and `q` points (each containing 16 `u32` elements) are concatenated into
///   a 32-element `input` array.
/// - The `input` pointer is passed to the system call via the A0 register.
/// - The A1 register is set to 0.
/// - The result of the operation is stored in the first 16 elements of the `input` array,
///   which are then copied back to the memory location pointed to by `p`.
///
/// ### Safety
///
/// The caller must ensure that `p` and `q` are valid pointers to memory that is properly aligned
/// to a four-byte boundary
#[allow(unused_variables)]
#[no_mangle]
pub extern "C" fn syscall_secp256k1_add(p: *mut [u32; 16], q: *const [u32; 16]) {
    println!("syscall_secp256k1_add");

    #[cfg(target_os = "ziskos")]
    {
        let (p_val, q_val) = unsafe { (*p, *q) };

        // Concatenate p and q
        let mut input: [u32; 32] = [0; 32];
        input[..16].copy_from_slice(&p_val);
        input[16..].copy_from_slice(&q_val);

        unsafe {
            asm!(
                "ecall",
                in("7a") crate::syscalls::SECP256K_ADD,
                in("a0") input,
                in("a1") 0
            );

            // Copy the result back to the p pointer
            (*p).copy_from_slice(&input[..16]);
        }
    }

    #[cfg(not(target_os = "ziskos"))]
    {
        unreachable!()
    }
}

/// Executes the `secp256k1_double` system call, which doubles the `p` Secp256k1 point
/// and updates `p` with the result.
///
/// - The `SECP256K_DOUBLE` constant is written to the A7 register.
/// - The `p` pointer is passed to the system call via the A0 register.
/// - The A1 register is set to 0.
/// - The result of the operation is stored in the memory location pointed to by `p`.
///
/// ### Safety
///
/// The caller must ensure that `p` is a valid pointer to data that is aligned along a four
/// byte boundary.
#[allow(unused_variables)]
#[no_mangle]
pub extern "C" fn syscall_secp256k1_double(p: *mut u32) {
    println!("syscall_secp256k1_double");

    #[cfg(target_os = "ziskos")]
    {
        unsafe {
            asm!(
                "ecall",
                in("a7") crate::syscalls::SECP256K_DOUBLE,
                in("a0") p,
                in("a1") 0
            );
        }
    }

    #[cfg(not(target_os = "ziskos"))]
    {
        unreachable!()
    }
}
