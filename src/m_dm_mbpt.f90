!=========================================================================
! This file is part of MOLGW.
! Author: Fabien Bruneval
!
! This module contains
! the reading or the calculation of correlated density matrix
!
!=========================================================================
#include "molgw.h"
module m_dm_mbpt
  use m_definitions
  use m_timing
  use m_warning
  use m_memory
  use m_atoms
  use m_basis_set
  use m_inputparam
  use m_spectral_function
  use m_selfenergy_tools
  use m_hamiltonian_tools
  use m_hamiltonian_wrapper
  use m_scf
  use m_multipole
  use m_pt_density_matrix
  use m_gw_selfenergy_grid
  use m_linear_response


contains


!=========================================================================
subroutine get_dm_mbpt(basis, occupation, energy, c_matrix, s_matrix, &
                       hamiltonian_kinetic, hamiltonian_nucleus, hamiltonian_fock)
  implicit none

  type(basis_set), intent(inout) :: basis
  real(dp), intent(in)           :: occupation(:, :)
  real(dp), intent(in)           :: energy(:, :)
  real(dp), intent(in)           :: c_matrix(:, :, :)
  real(dp), intent(in)           :: s_matrix(:, :)
  real(dp), intent(in)           :: hamiltonian_kinetic(:, :)
  real(dp), intent(in)           :: hamiltonian_nucleus(:, :)
  real(dp), intent(inout)        :: hamiltonian_fock(:, :, :)
  !=====
  integer                    :: nstate, nocc
  logical                    :: density_matrix_found
  integer                    :: file_density_matrix, reading_status
  integer                    :: ispin, istate
  type(spectral_function)    :: wpol
  type(energy_contributions) :: en_dm_corr
  real(dp), allocatable       :: h_ii(:, :), exchange_ii(:, :)
  real(dp), allocatable       :: p_matrix_corr(:, :, :)
  real(dp), allocatable       :: hamiltonian_hartree_corr(:, :)
  real(dp), allocatable       :: hamiltonian_exx_corr(:, :, :)
  real(dp), allocatable       :: c_matrix_tmp(:, :, :), p_matrix_mo(:, :, :)
  real(dp), allocatable       :: occupation_tmp(:, :), natural_occupation(:, :)
  real(dp), allocatable       :: energy_qp(:, :)
  !=====

  nstate = SIZE(c_matrix, DIM=2)

  call clean_allocate('Correlated density matrix', p_matrix_corr, basis%nbf, basis%nbf, nspin)
  call clean_allocate('Correlated Hartree potential', hamiltonian_hartree_corr, basis%nbf, basis%nbf)
  call clean_allocate('Correlated exchange operator', hamiltonian_exx_corr, basis%nbf, basis%nbf, nspin)
  p_matrix_corr(:, :, :) = 0.0_dp

  !
  ! Three possibilities: read_fchk , pt_density_matrix, DENSITY_MATRIX
  !


  ! Option 1:
  ! Is there a Gaussian formatted checkpoint file to be read?
  if( read_fchk /= 'NO') call read_gaussian_fchk(read_fchk, 'gaussian.fchk', basis, p_matrix_corr)


  ! Option 2:
  ! Calculate a MBPT density matrix if requested
  if( TRIM(pt_density_matrix) /= 'NO' ) then
    call selfenergy_set_state_range(nstate, occupation)
    call fock_density_matrix(basis, occupation, energy, c_matrix, hamiltonian_fock, p_matrix_corr)

    select case(TRIM(pt_density_matrix))
    case('ONE-RING')
      ! This keyword calculates the 1-ring density matrix as it is derived in PT2 theory
      call onering_density_matrix(occupation, energy, c_matrix, p_matrix_corr)
    case('PT2')
      ! This keyword calculates the PT2 density matrix as it is derived in PT2 theory (differs from MP2 density matrix)
      call pt2_density_matrix(occupation, energy, c_matrix, p_matrix_corr)
    case('GW','G0W0')
      ! This keyword calculates the GW density matrix as it is derived in the new GW theory
      call wpol%init(nstate, occupation, 0)
      call polarizability(.TRUE., .TRUE., basis, occupation, energy, c_matrix, en_dm_corr%rpa, en_dm_corr%gw, wpol)
      call gw_density_matrix(occupation, energy, c_matrix, wpol, p_matrix_corr)
      call wpol%destroy()
    case('EVGW', 'GNWN')
      ! This keyword calculates the GW density matrix calculated with GW QP energies
      allocate(energy_qp, MOLD=energy)
      call read_energy_qp(nstate, energy_qp, reading_status)
      if( reading_status /= 0 ) then
        call issue_warning('File energy_qp not found: assuming 1st iteration')
        energy_qp(:, :) = energy(:, :)
      endif
      call wpol%init(nstate, occupation, 0)
      call polarizability(.TRUE., .TRUE., basis, occupation, energy_qp, c_matrix, en_dm_corr%rpa, en_dm_corr%gw, wpol)
      call gw_density_matrix(occupation, energy_qp, c_matrix, wpol, p_matrix_corr)
      call wpol%destroy()
      deallocate(energy_qp)
    case('GW_IMAGINARY', 'G0W0_IMAGINARY')
      ! This keyword calculates the GW density matrix as it is derived in the new GW theory
      ! using an imaginary axis integral
      call wpol%init(nstate, occupation, nomega_chi_imag, grid_type=IMAGINARY_QUAD)
      call polarizability_grid_scalapack(occupation, energy, c_matrix, en_dm_corr%rpa, en_dm_corr%gw, wpol)
      call gw_density_matrix_imag(occupation, energy, c_matrix, wpol, p_matrix_corr)
      call wpol%destroy()
    case('GW_DYSON', 'G0W0_DYSON')
      ! This keyword calculates the GW density matrix as it is derived in the new GW theory
      ! using an imaginary axis integral
      call wpol%init(nstate, occupation, nomega_chi_imag, grid_type=IMAGINARY_QUAD)
      call polarizability_grid_scalapack(occupation, energy, c_matrix, en_dm_corr%rpa, en_dm_corr%gw, wpol)
      call gw_density_matrix_dyson_imag(occupation, energy, c_matrix, wpol, p_matrix_corr)
      call wpol%destroy()
    case('HF')
    case('HF_SECOND_ORDER')
      call fock_density_matrix_second_order(basis, occupation, energy, c_matrix, hamiltonian_fock, p_matrix_corr)
    case default
      call die('get_dm_mbpt: pt_density_matrix choice does not exist')
    end select
  endif


  ! Option 3:
  ! If no p_matrix_corr is present yet, then try to read it from a DENSITY_MATRIX file
  if( ALL( ABS(p_matrix_corr(:, :, :)) < 0.01_dp ) ) then
    inquire(file='DENSITY_MATRIX', exist=density_matrix_found)
    if( density_matrix_found) then
      write(stdout, '(/,1x,a)') 'Reading a MOLGW density matrix file: DENSITY_MATRIX'
      open(newunit=file_density_matrix, file='DENSITY_MATRIX', form='unformatted', action='read')
      do ispin=1, nspin
        read(file_density_matrix) p_matrix_corr(:, :, ispin)
      enddo
      close(file_density_matrix)
    else
      call die('get_dm_mbpt: no correlated density matrix read or calculated though input file suggests you really want one')
    endif

  endif


  !
  ! Get the natural occupation number by diagonalizing C**T * S * P * S *C
  !
  allocate(natural_occupation(nstate, nspin))

  call clean_allocate('Matrix S * C', c_matrix_tmp, basis%nbf, nstate, nspin)
  call clean_allocate('Density matrix P_MO', p_matrix_mo, nstate, nstate, nspin)

  do ispin=1, nspin
    !c_matrix_tmp(:,:,ispin) = MATMUL( s_matrix, c_matrix(:,:,ispin) )
    call DSYMM('L', 'L', basis%nbf, nstate, 1.0d0, s_matrix(1,1),basis%nbf, &
                                              c_matrix(1, 1, ispin), basis%nbf,  &
                                        0.0d0, c_matrix_tmp(1, 1, ispin), basis%nbf)
  enddo
  call matrix_ao_to_mo(c_matrix_tmp, p_matrix_corr, p_matrix_mo)

  ! Multiply by -1 so to order the eigenvalues (natural occupations) from the largest to the smallest
  p_matrix_mo(:, :, :) = -p_matrix_mo(:, :, :)
  do ispin=1, nspin
    call diagonalize_scalapack(scf_diago_flavor, scalapack_block_min, p_matrix_mo(:, :, ispin), natural_occupation(:, ispin))
    ! restore the correct positive sign here
    natural_occupation(:, ispin) = -natural_occupation(:, ispin)
    write(stdout, '(/,1x,a,i3)')  'Natural occupations for spin: ', ispin
    write(stdout, '(10(2x,f14.6))') natural_occupation(:, ispin)
    write(stdout, '(1x,a,f14.6)') 'Trace:', SUM(natural_occupation(:, ispin))
    write(stdout, *)

    !
    ! Get the natural orbital in the AO basis
    ! C_NO^AO = C * C_NO^MO
    c_matrix_tmp(:, :, ispin) = MATMUL( c_matrix(:, :, ispin) , p_matrix_mo(:, :, ispin) )

  enddo
  if( ANY(natural_occupation(:, :) < -0.1_dp) ) then
    write(stdout, '(1x,a,f12.6)') 'Too negative natural occupation: ', MINVAL(natural_occupation)
    call die('get_dm_mbpt: better stop now')
  endif

  if( print_cube_ ) then
    call plot_cube_wfn('MBPT', basis, natural_occupation, c_matrix_tmp)
  endif
  if( print_wfn_ ) then
    call plot_rho('MBPT', basis, natural_occupation, c_matrix_tmp)
  endif
  if( print_wfn_files_ ) then
    call print_wfn_file('MBPT', basis, natural_occupation, c_matrix_tmp, en_dm_corr%total)
  endif

  call clean_deallocate('Density matrix P_MO', p_matrix_mo)
  call clean_deallocate('Matrix S * C', c_matrix_tmp)
  deallocate(natural_occupation)


  if( print_hartree_ .OR. use_correlated_density_matrix_ ) then

    !
    ! Nucleus-nucleus repulsion contribution to the energy
    call nucleus_nucleus_energy(en_dm_corr%nuc_nuc)
    en_dm_corr%kinetic = SUM( hamiltonian_kinetic(:, :) * SUM(p_matrix_corr(:, :, :), DIM=3) )
    en_dm_corr%nucleus = SUM( hamiltonian_nucleus(:, :) * SUM(p_matrix_corr(:, :, :), DIM=3) )

    call calculate_hartree(basis, p_matrix_corr, hamiltonian_hartree_corr, eh=en_dm_corr%hartree)

    call calculate_exchange(basis, p_matrix_corr, hamiltonian_exx_corr, ex=en_dm_corr%exx)

    en_dm_corr%totalexx = en_dm_corr%nuc_nuc + en_dm_corr%kinetic + en_dm_corr%nucleus +  en_dm_corr%hartree + en_dm_corr%exx
    write(stdout, '(/,1x,a)') 'Energies from correlated density matrix'
    write(stdout, '(a35,1x,f19.10)')   'Kinetic Energy (Ha):', en_dm_corr%kinetic
    write(stdout, '(a35,1x,f19.10)')   'Nucleus Energy (Ha):', en_dm_corr%nucleus
    write(stdout, '(a35,1x,f19.10)')   'Hartree Energy (Ha):', en_dm_corr%hartree
    write(stdout, '(a35,1x,f19.10)')  'Exchange Energy (Ha):', en_dm_corr%exx
    write(stdout, '(a35,1x,f19.10)') 'Total EXX Energy (Ha):', en_dm_corr%totalexx


    if( ABS(en_dm_corr%gw) > 1.0e-8_dp ) then
      write(stdout, '(a35,1x,f19.10)')  'GW correlation Energy (Ha):', en_dm_corr%gw
      en_dm_corr%total = en_dm_corr%totalexx + en_dm_corr%gw
      write(stdout, '(a35,1x,f19.10)')  'Total GM Energy (Ha):', en_dm_corr%total
      if( print_yaml_ ) call print_energy_yaml('linearized gw dm energy', en_dm_corr)
    else
      if( print_yaml_ ) call print_energy_yaml('correlated dm energy', en_dm_corr)
    endif

    nocc = get_number_occupied_states(occupation)
    allocate(h_ii(nstate, nspin))

    call matrix_ao_to_mo_diag(c_matrix, hamiltonian_hartree_corr, h_ii)
    call dump_out_energy('=== Hartree expectation value from correlated density matrix ===', occupation, h_ii)
    write(stdout, '(1x,a,2(3x,f12.6))') 'Hartree  HOMO expectation (eV):', h_ii(nocc, :) * Ha_eV

    call matrix_ao_to_mo_diag(c_matrix, hamiltonian_exx_corr, h_ii)
    call dump_out_energy('=== Exchange expectation value from correlated density matrix ===', occupation, h_ii)
    write(stdout, '(1x,a,2(3x,f12.6))') 'Exchange HOMO expectation (eV):', h_ii(nocc, :) * Ha_eV
    deallocate(h_ii)

  endif

  if( print_multipole_ ) then
    call get_c_matrix_from_p_matrix(p_matrix_corr, c_matrix_tmp, occupation_tmp)
    if( .FALSE. ) call plot_rho('MBPT', basis, occupation_tmp, c_matrix_tmp)
    if( .FALSE. ) call write_cube_from_header('MBPT', basis, occupation_tmp, c_matrix_tmp)
    if( print_multipole_ ) then
      call static_dipole(basis, occupation_tmp, c_matrix_tmp)
      call static_quadrupole(basis, occupation_tmp, c_matrix_tmp)
    endif
    deallocate(c_matrix_tmp)
    deallocate(occupation_tmp)
  endif

  if( use_correlated_density_matrix_ ) then
    !
    ! Since the density matrix p_matrix is updated,
    ! one needs to recalculate the hartree and the exchange potentials
    ! let us include the old hartree in hamiltonian_xc and the new one in hamiltonian_exchange
    do ispin=1, nspin
      hamiltonian_fock(:, :, ispin) = hamiltonian_kinetic(:, :) + hamiltonian_nucleus(:, :) + hamiltonian_hartree_corr(:, :)  &
                                   + hamiltonian_exx_corr(:, :, ispin)
    enddo

  endif

  write(stdout, *)
  call clean_deallocate('Correlated density matrix', p_matrix_corr)
  call clean_deallocate('Correlated Hartree potential', hamiltonian_hartree_corr)
  call clean_deallocate('Correlated exchange operator', hamiltonian_exx_corr)


end subroutine get_dm_mbpt


!=========================================================================
subroutine fock_density_matrix(basis, occupation, energy, c_matrix, hfock, p_matrix)
  implicit none

  type(basis_set), intent(in)         :: basis
  real(dp), intent(in)                :: occupation(:, :), energy(:, :)
  real(dp), intent(in)                :: c_matrix(:, :, :)
  real(dp), intent(in)                :: hfock(:, :, :)
  real(dp), intent(out)               :: p_matrix(:, :, :)
  !=====
  integer  :: nstate
  integer  :: pstate, qstate
  integer  :: istate, jstate
  integer  :: astate, bstate
  integer  :: pqspin
  real(dp), allocatable :: p_matrix_mo(:, :, :)
  real(dp), allocatable :: hfock_mo(:, :, :)
  !=====

  call start_clock(timing_mbpt_dm)
  write(stdout, '(/,1x,a)') 'Calculate the perturbative Fock density matrix'

  nstate = SIZE(occupation, DIM=1)

  call clean_allocate('Density matrix P_MO', p_matrix_mo, nstate, nstate, nspin)
  call clean_allocate('Fock matrix F_MO', hfock_mo, nstate, nstate, nspin)

  call matrix_ao_to_mo(c_matrix, hfock, hfock_mo)

  p_matrix_mo(:, :, :) = 0.0_dp
  do pqspin=1, nspin
    ! Fill the diagonal
    do pstate=1, nstate
      p_matrix_mo(pstate, pstate, pqspin) = occupation(pstate, pqspin)
    enddo

    do istate=ncore_G+1, nhomo_G
      do astate=nhomo_G+1, nvirtual_G-1
        p_matrix_mo(istate, astate, pqspin) = hfock_mo(istate, astate, pqspin)  &
                                               / ( energy(istate, pqspin) - energy(astate, pqspin) ) * spin_fact
        p_matrix_mo(astate, istate, pqspin) = p_matrix_mo(istate, astate, pqspin)
      enddo
    enddo
  enddo

  call matrix_mo_to_ao(c_matrix, p_matrix_mo, p_matrix)

  call clean_deallocate('Density matrix P_MO', p_matrix_mo)
  call clean_deallocate('Fock matrix F_MO', hfock_mo)

  call stop_clock(timing_mbpt_dm)

end subroutine fock_density_matrix


!=========================================================================
subroutine fock_density_matrix_second_order(basis, occupation, energy, c_matrix, hfock, p_matrix)
  implicit none

  type(basis_set), intent(in)         :: basis
  real(dp), intent(in)                :: occupation(:, :), energy(:, :)
  real(dp), intent(in)                :: c_matrix(:, :, :)
  real(dp), intent(in)                :: hfock(:, :, :)
  real(dp), intent(inout)             :: p_matrix(:, :, :)
  !=====
  integer  :: nstate
  integer  :: pstate, qstate
  integer  :: istate, jstate
  integer  :: astate, bstate
  integer  :: pqspin
  real(dp), allocatable :: p_matrix_mo(:, :, :), p_matrix_ao(:, :, :)
  real(dp), allocatable :: delta_sigma_mo(:, :, :)
  !=====

  call start_clock(timing_mbpt_dm)
  write(stdout, '(/,1x,a)') 'Calculate the perturbative Fock density matrix'

  nstate = SIZE(occupation, DIM=1)

  call clean_allocate('Density matrix P_MO', p_matrix_mo, nstate, nstate, nspin)
  call clean_allocate('Density matrix P_AO', p_matrix_ao, basis%nbf, basis%nbf, nspin)
  call clean_allocate('Delta Sigma_MO', delta_sigma_mo, nstate, nstate, nspin)

  ! < p | Sigma_x - v_xc | q > = < p | H_fock - H_gKS | q >
  !                            = < p | H_fock | q >   - energy_p \delta_pq
  call matrix_ao_to_mo(c_matrix, hfock, delta_sigma_mo)
  do pstate=1, nstate
    delta_sigma_mo(pstate, pstate, :) = delta_sigma_mo(pstate, pstate, :) - energy(pstate, :)
  enddo


  p_matrix_mo(:, :, :) = 0.0_dp
  !
  ! occupied - occupied block
  do pqspin=1, nspin
    do istate=ncore_G+1, nhomo_G
      do jstate=ncore_G+1, nhomo_G
        do astate=nhomo_G+1, nvirtual_G-1
          p_matrix_mo(istate, jstate, pqspin) = p_matrix_mo(istate, jstate, pqspin) &
             - spin_fact * delta_sigma_mo(istate, astate, pqspin)  * delta_sigma_mo(astate, jstate, pqspin) &
                     / ( ( energy(astate, pqspin) - energy(istate, pqspin) ) * ( energy(astate, pqspin) - energy(jstate, pqspin) ) )
        enddo
      enddo
    enddo
  enddo
  !
  ! virtual - virtual block
  do pqspin=1, nspin
    do astate=nhomo_G+1, nvirtual_G-1
      do bstate=nhomo_G+1, nvirtual_G-1
        do istate=ncore_G+1, nhomo_G
          p_matrix_mo(astate, bstate, pqspin) = p_matrix_mo(astate, bstate, pqspin) &
             + spin_fact * delta_sigma_mo(astate, istate, pqspin)  * delta_sigma_mo(istate, bstate, pqspin) &
                     / ( ( energy(istate, pqspin) - energy(astate, pqspin) ) * ( energy(istate, pqspin) - energy(bstate, pqspin) ) )
        enddo
      enddo
    enddo
  enddo
  !
  ! occupied - virtual block
  do pqspin=1, nspin
    do istate=ncore_G+1, nhomo_G
      do astate=nhomo_G+1, nvirtual_G-1

        do bstate=nhomo_G+1, nvirtual_G-1
          p_matrix_mo(istate, astate, pqspin) = p_matrix_mo(istate, astate, pqspin) &
             + spin_fact * delta_sigma_mo(istate, bstate, pqspin)  * delta_sigma_mo(bstate, astate, pqspin) &
                     / ( ( energy(istate, pqspin) - energy(astate, pqspin) ) * ( energy(istate, pqspin) - energy(bstate, pqspin) ) )
        enddo
        do jstate=ncore_G+1, nhomo_G
          p_matrix_mo(istate, astate, pqspin) = p_matrix_mo(istate, astate, pqspin) &
             - spin_fact * delta_sigma_mo(istate, bstate, pqspin)  * delta_sigma_mo(bstate, astate, pqspin) &
                     / ( ( energy(astate, pqspin) - energy(istate, pqspin) ) * ( energy(astate, pqspin) - energy(jstate, pqspin) ) )
        enddo

      enddo
    enddo
  enddo
  !
  ! virtual - occupied block (by symmetry)
  do pqspin=1, nspin
    do astate=nhomo_G+1, nvirtual_G-1
      do istate=ncore_G+1, nhomo_G
        p_matrix_mo(astate, istate, pqspin) = p_matrix_mo(istate, astate, pqspin)
      enddo
    enddo
  enddo

  call matrix_mo_to_ao(c_matrix, p_matrix_mo, p_matrix_ao)

  p_matrix(:, :, :) = p_matrix(:, :, :) + p_matrix_ao(:, :, :)

  call clean_deallocate('Density matrix P_MO', p_matrix_mo)
  call clean_deallocate('Density matrix P_AO', p_matrix_ao)
  call clean_deallocate('Delta Sigma F_MO', delta_sigma_mo)

  call stop_clock(timing_mbpt_dm)

end subroutine fock_density_matrix_second_order


!=========================================================================
end module m_dm_mbpt
!=========================================================================
