!======================================================================
! This file is part of MOLGW.
!
! The following lines have been generated by the python script input_variables.py
! Do not alter them directly: they will be overriden sooner or later by the script
! To add a new input variable, modify the script directly
! Generated by input_variables.py on 19 March 2025
!======================================================================

 real(dp), protected :: auto_auxil_fsam
 integer, protected :: auto_auxil_lmaxinc
 character(len=3), protected :: auto_occupation
 logical, protected :: auto_occupation_
 character(len=256), protected :: comment
 character(len=256), protected :: ecp_auxil_basis
 character(len=256), protected :: ecp_basis
 character(len=256), protected :: ecp_elements
 character(len=256), protected :: ecp_quality
 character(len=256), protected :: ecp_type
 character(len=3), protected :: eri3_genuine
 logical, protected :: eri3_genuine_
 real(dp), protected :: even_tempered_alpha
 real(dp), protected :: even_tempered_beta
 character(len=256), protected :: even_tempered_n_list
 character(len=256), protected :: gaussian_type
 character(len=3), protected :: incore
 logical, protected :: incore_
 character(len=3), protected :: memory_evaluation
 logical, protected :: memory_evaluation_
 character(len=256), protected :: move_nuclei
 integer, protected :: nstep
 character(len=256), protected :: scf
 character(len=3), protected :: complex_scf
 logical, protected :: complex_scf_
 real(dp), protected :: tolforce
 character(len=3), protected :: x2c
 logical, protected :: x2c_
 real(dp), protected :: c_speedlight
 character(len=3), protected :: parabolic_conf
 logical, protected :: parabolic_conf_
 real(dp), protected :: rwconfinement
 character(len=3), protected :: harmonium
 logical, protected :: harmonium_
 character(len=3), protected :: approx_H_x2c
 logical, protected :: approx_H_x2c_
 character(len=3), protected :: check_CdSC_x2c
 logical, protected :: check_CdSC_x2c_
 integer, protected :: eri3_nbatch
 integer, protected :: eri3_npcol
 integer, protected :: eri3_nprow
 real(dp), protected :: grid_memory
 character(len=3), protected :: mpi_poorman
 logical, protected :: mpi_poorman_
 integer, protected :: scalapack_block_min
 character(len=256), protected :: basis_path
 integer, protected :: cube_nx
 integer, protected :: cube_ny
 integer, protected :: cube_nz
 integer, protected :: cube_state_min
 integer, protected :: cube_state_max
 character(len=3), protected :: force_energy_qp
 logical, protected :: force_energy_qp_
 character(len=3), protected :: ignore_bigrestart
 logical, protected :: ignore_bigrestart_
 character(len=3), protected :: print_bigrestart
 logical, protected :: print_bigrestart_
 character(len=3), protected :: print_cube
 logical, protected :: print_cube_
 character(len=3), protected :: print_transition_density
 logical, protected :: print_transition_density_
 character(len=3), protected :: print_wfn_files
 logical, protected :: print_wfn_files_
 character(len=3), protected :: print_all_MO_wfn_file
 logical, protected :: print_all_MO_wfn_file_
 character(len=3), protected :: print_density_matrix
 logical, protected :: print_density_matrix_
 character(len=3), protected :: print_eri
 logical, protected :: print_eri_
 character(len=3), protected :: print_hartree
 logical, protected :: print_hartree_
 character(len=3), protected :: print_multipole
 logical, protected :: print_multipole_
 character(len=3), protected :: print_pdos
 logical, protected :: print_pdos_
 character(len=3), protected :: print_restart
 logical, protected :: print_restart_
 character(len=3), protected :: print_rho_grid
 logical, protected :: print_rho_grid_
 character(len=3), protected :: print_sigma
 logical, protected :: print_sigma_
 character(len=3), protected :: print_spatial_extension
 logical, protected :: print_spatial_extension_
 character(len=3), protected :: print_w
 logical, protected :: print_w_
 character(len=3), protected :: print_wfn
 logical, protected :: print_wfn_
 character(len=3), protected :: print_yaml
 logical, protected :: print_yaml_
 character(len=256), protected :: read_fchk
 character(len=256), protected :: yaml_output
 character(len=3), protected :: calc_dens_disc
 logical, protected :: calc_dens_disc_
 character(len=3), protected :: calc_q_matrix
 logical, protected :: calc_q_matrix_
 character(len=3), protected :: calc_spectrum
 logical, protected :: calc_spectrum_
 character(len=3), protected :: print_cube_diff_tddft
 logical, protected :: print_cube_diff_tddft_
 character(len=3), protected :: print_cube_rho_tddft
 logical, protected :: print_cube_rho_tddft_
 character(len=3), protected :: print_c_matrix_cmplx_hdf5
 logical, protected :: print_c_matrix_cmplx_hdf5_
 character(len=3), protected :: print_p_matrix_MO_block_hdf5
 logical, protected :: print_p_matrix_MO_block_hdf5_
 character(len=3), protected :: print_dens_traj
 logical, protected :: print_dens_traj_
 character(len=3), protected :: print_dens_traj_points_set
 logical, protected :: print_dens_traj_points_set_
 character(len=3), protected :: print_dens_traj_tddft
 logical, protected :: print_dens_traj_tddft_
 character(len=3), protected :: print_line_rho_diff_tddft
 logical, protected :: print_line_rho_diff_tddft_
 character(len=3), protected :: print_line_rho_tddft
 logical, protected :: print_line_rho_tddft_
 character(len=3), protected :: print_tddft_matrices
 logical, protected :: print_tddft_matrices_
 character(len=3), protected :: print_charge_tddft
 logical, protected :: print_charge_tddft_
 character(len=3), protected :: print_tddft_restart
 logical, protected :: print_tddft_restart_
 character(len=3), protected :: read_tddft_restart
 logical, protected :: read_tddft_restart_
 real(dp), protected :: write_step
 real(dp), protected :: calc_charge_step
 character(len=3), protected :: analytic_chi
 logical, protected :: analytic_chi_
 character(len=3), protected :: assume_scf_converged
 logical, protected :: assume_scf_converged_
 integer, protected :: acfd_nlambda
 character(len=256), protected :: ci_greens_function
 integer, protected :: ci_nstate
 integer, protected :: ci_nstate_self
 integer, protected :: ci_spin_multiplicity
 character(len=256), protected :: ci_type
 character(len=3), protected :: cphf_cpks_0
 logical, protected :: cphf_cpks_0_
 integer, protected :: dft_core
 character(len=256), protected :: ecp_small_basis
 real(dp), protected :: eta
 character(len=3), protected :: frozencore
 logical, protected :: frozencore_
 character(len=3), protected :: g3w2_skip_vvv
 logical, protected :: g3w2_skip_vvv_
 character(len=3), protected :: g3w2_skip_vv
 logical, protected :: g3w2_skip_vv_
 character(len=3), protected :: g3w2_static_approximation
 logical, protected :: g3w2_static_approximation_
 character(len=3), protected :: gwgamma_tddft
 logical, protected :: gwgamma_tddft_
 real(dp), protected :: mu_origin
 integer, protected :: ncoreg
 integer, protected :: ncorew
 integer, protected :: nexcitation
 integer, protected :: nomega_chi_imag
 integer, protected :: nomega_chi_real
 integer, protected :: nomega_sigma
 integer, protected :: nomega_sigma_calc
 integer, protected :: nstep_dav
 integer, protected :: nstep_gw
 integer, protected :: nvel_projectile
 integer, protected :: nvirtualg
 integer, protected :: nvirtualw
 character(len=256), protected :: postscf
 character(len=256), protected :: postscf_diago_flavor
 character(len=256), protected :: pt3_a_diagrams
 character(len=256), protected :: pt_density_matrix
 real(dp), protected :: rcut_mbpt
 real(dp), protected :: scissor
 integer, protected :: selfenergy_state_max
 integer, protected :: selfenergy_state_min
 integer, protected :: selfenergy_state_range
 character(len=256), protected :: small_basis
 real(dp), protected :: step_sigma
 real(dp), protected :: step_sigma_calc
 character(len=256), protected :: stopping
 integer, protected :: stopping_nq
 real(dp), protected :: stopping_dq
 character(len=3), protected :: tda
 logical, protected :: tda_
 character(len=256), protected :: tddft_grid_quality
 real(dp), protected :: toldav
 character(len=3), protected :: triplet
 logical, protected :: triplet_
 character(len=3), protected :: use_correlated_density_matrix
 logical, protected :: use_correlated_density_matrix_
 character(len=3), protected :: virtual_fno
 logical, protected :: virtual_fno_
 character(len=256), protected :: w_screening
 real(dp), protected :: excit_dir(3)
 real(dp), protected :: excit_kappa
 character(len=256), protected :: excit_name
 real(dp), protected :: excit_width
 real(dp), protected :: excit_time0
 integer, protected :: tddft_history
 integer, protected :: n_iter
 integer, protected :: n_restart_tddft
 integer, protected :: ncore_tddft
 character(len=256), protected :: tddft_predictor_corrector
 character(len=256), protected :: tddft_propagator
 real(dp), protected :: projectile_charge_scaling
 real(dp), protected :: r_disc
 character(len=3), protected :: tddft_frozencore
 logical, protected :: tddft_frozencore_
 character(len=256), protected :: tddft_wfn_t0
 real(dp), protected :: tddft_energy_shift
 real(dp), protected :: tddft_charge
 character(len=3), protected :: tddft_force
 logical, protected :: tddft_force_
 real(dp), protected :: tddft_magnetization
 real(dp), protected :: time_sim
 real(dp), protected :: time_step
 real(dp), protected :: vel_projectile(3)
 real(dp), protected :: tolscf_tddft
 real(dp), protected :: alpha_hybrid
 real(dp), protected :: alpha_mixing
 real(dp), protected :: beta_hybrid
 real(dp), protected :: density_matrix_damping
 real(dp), protected :: diis_switch
 real(dp), protected :: gamma_hybrid
 real(dp), protected :: kappa_hybrid
 character(len=256), protected :: grid_quality
 character(len=256), protected :: init_hamiltonian
 character(len=256), protected :: integral_quality
 real(dp), protected :: kerker_k0
 real(dp), protected :: level_shifting_energy
 real(dp), protected :: min_overlap
 character(len=256), protected :: mixing_scheme
 real(dp), protected :: tolscf
 integer, protected :: npulay_hist
 integer, protected :: nscf
 character(len=256), protected :: partition_scheme
 character(len=256), protected :: scf_diago_flavor
 character(len=3), protected :: noft_complex
 logical, protected :: noft_complex_
 character(len=3), protected :: noft_hessian
 logical, protected :: noft_hessian_
 character(len=3), protected :: noft_nophases
 logical, protected :: noft_nophases_
 character(len=3), protected :: noft_dft
 logical, protected :: noft_dft_
 character(len=3), protected :: noft_rsinter
 logical, protected :: noft_rsinter_
 character(len=3), protected :: noft_lowmemERI
 logical, protected :: noft_lowmemERI_
 character(len=3), protected :: noft_fcidump
 logical, protected :: noft_fcidump_
 character(len=3), protected :: noft_NOTupdateOCC
 logical, protected :: noft_NOTupdateOCC_
 character(len=3), protected :: noft_NOTupdateORB
 logical, protected :: noft_NOTupdateORB_
 character(len=3), protected :: noft_NOTvxc
 logical, protected :: noft_NOTvxc_
 character(len=256), protected :: noft_functional
 character(len=3), protected :: noft_printdmn
 logical, protected :: noft_printdmn_
 character(len=3), protected :: noft_printswdmn
 logical, protected :: noft_printswdmn_
 character(len=3), protected :: noft_printints
 logical, protected :: noft_printints_
 character(len=3), protected :: noft_readCOEF
 logical, protected :: noft_readCOEF_
 character(len=3), protected :: noft_readFdiag
 logical, protected :: noft_readFdiag_
 character(len=3), protected :: noft_readGAMMAS
 logical, protected :: noft_readGAMMAS_
 character(len=3), protected :: noft_readOCC
 logical, protected :: noft_readOCC_
 character(len=3), protected :: noft_NR_OCC
 logical, protected :: noft_NR_OCC_
 character(len=3), protected :: noft_QC_ORB
 logical, protected :: noft_QC_ORB_
 integer, protected :: noft_ithresh_lambda
 real(dp), protected :: noft_Lpower
 integer, protected :: noft_npairs
 integer, protected :: noft_ncoupled
 integer, protected :: noft_ndiis
 integer, protected :: noft_nscf
 character(len=3), protected :: noft_restart
 logical, protected :: noft_restart_
 real(dp), protected :: noft_tolE
 real(dp), protected :: charge
 real(dp), protected :: electric_field_x
 real(dp), protected :: electric_field_y
 real(dp), protected :: electric_field_z
 character(len=256), protected :: length_unit
 real(dp), protected :: magnetization
 integer, protected :: natom
 integer, protected :: nghost
 integer, protected :: nspin
 real(dp), protected :: temperature
 character(len=256), protected :: xyz_file


!======================================================================
