# linux-mainline_%.bbappend
#
# Real-Time Optimization for ColorCreator Project
# Apply RT configuration fragment and bootargs patch
#

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Add RT optimization config fragment
SRC_URI += "file://rt-optimization.cfg"

# Add RT bootargs patch (adds isolcpus, nohz_full, rcu_nocbs, cpufreq governor)
SRC_URI += "file://003-rt-bootargs.patch"

# Summary of RT optimizations applied:
# 1. PREEMPT_VOLUNTARY instead of PREEMPT_NONE (via rt-optimization.cfg)
# 2. HZ=1000 instead of HZ=100 (via rt-optimization.cfg)
# 3. Performance governor at boot (via bootargs patch)
# 4. NO_HZ_FULL (via rt-optimization.cfg)
# 5. CPU1 isolated for RT tasks (via bootargs patch)
# 6. PWM driver embedded (via rt-optimization.cfg)
# 7. RT debugging enabled (via rt-optimization.cfg)
