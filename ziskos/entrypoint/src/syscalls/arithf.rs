#[cfg(target_os = "ziskos")]
use core::arch::asm;
use std::usize;

/// Executes the add_256 syscall
///
/// ### Safety
///
/// The caller must ensure that `state` is valid pointer to data that is aligned along a four
/// byte boundary.
#[allow(unused_variables)]
#[no_mangle]
pub extern "C" fn syscall_add_256_f(state: *mut [u64; 12]) {
    syscall_binary256(state, super::ADD_256);
}

/// Executes the addc_256 syscall (add with carry)
///
/// ### Safety
///
/// The caller must ensure that `a` is valid pointer to data that is aligned along a four
/// byte boundary.
#[allow(unused_variables)]
#[no_mangle]
pub extern "C" fn syscall_addc_256_f(state: *mut [u64; 9]) {
    syscall_binary256(state, super::ADDC_256);
}

fn syscall_binary256<const SIZE: usize>(state: *mut [u64; SIZE], op: u32) {
    #[cfg(target_os = "ziskos")]
    unsafe {
        asm!(
            "ecall",
            in("a7") op,
            in("a0") state,
            in("a1") 0
        );
    }

    #[cfg(not(target_os = "ziskos"))]
    {
        unreachable!()
    }
}
