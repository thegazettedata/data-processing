def moe(vals):
	""" 
	do math to get the 
	margin of error grouped by
	larger geography
	"""

	import math

	return int(round(math.sqrt(sum(x*x for x in vals)),0))
	
estimates = [1341]
moes = [982]
moe = moe(moes)
sum_estimate = sum(estimates)
lower_estimate = sum_estimate - moe
upper_estimate = sum_estimate + moe
percent_margin = float(moe) / sum_estimate * 100

print 'Sum:', sum_estimate
print 'MOE:', moe
print 'Range:', lower_estimate, '-', upper_estimate 
print 'Percent margin:', percent_margin, '%'