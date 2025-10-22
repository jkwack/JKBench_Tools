program usm__out_of_bound
  use omp_lib
  implicit none

  integer, parameter :: LENGTH = 64
  integer, allocatable :: A(:)
  integer :: i
  !$omp allocators allocate(allocator(omp_target_host_mem_alloc): A)
  allocate( A(1 : LENGTH) )

  !$omp target teams distribute parallel do has_device_addr(A)
  do i=1, LENGTH
    A(i) = i
  end do

  !$omp target teams distribute parallel do has_device_addr(A)
  do i=1, LENGTH
    A(1) = A(1)+i
  end do

  deallocate(A)
end program usm__out_of_bound

