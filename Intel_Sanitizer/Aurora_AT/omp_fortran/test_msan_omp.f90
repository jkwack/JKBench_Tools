program msan_fortran
        use omp_lib
        implicit none
        integer, parameter :: LENGTH = 64
        integer, allocatable :: A(:)
        integer :: i

        !$omp allocators allocate(allocator(omp_target_device_mem_alloc): A)
        allocate(A(1:LENGTH))

        !$omp target teams distribute parallel do has_device_addr(A)
        do i=1,10
        ! Trying to use uninitialized device USM A(i) here, resulted in MSAN error
          if(A(i)==i) then
                A(i)=42
          end if
        end do
        !$omp end target teams distribute parallel do
        deallocate(A)
end program msan_fortran

