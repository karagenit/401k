# calculate how much I should contribute to my 401k each year

years = 65 - 23 # retirement age - current age (including 0 as first year!)
start_salary = 125000
end_salary = 500000
salaries = (0..years).map { |i| (start_salary + (end_salary - start_salary) * (i.to_f / years)).to_i }
k401_limit = 23000

def tax_bracket(income) # 2024 single filer tax brackets
	return 0.10 if income <  11600
	return 0.12 if income <  47150
	return 0.22 if income < 100525
	return 0.24 if income < 191950
	return 0.32 if income < 243725
	return 0.35 if income < 609350
	return 0.37
end

# start at 6% to get the employer match, then increment when advantageous
contributions = salaries.map { |sal| (sal * 0.06).to_i }
contributions.map! { |con| con > k401_limit ? k401_limit : con }
# TODO add employer match to contributions too

p contributions
puts

roi = 1.07 # post-inflation average stock market return

loop do
	# add the salaries * 6% to include the employer match
	returns = contributions.each_with_index.map { |cont,i| ((cont + (salaries[i] * 0.06)) * (roi ** (years - i))).to_i }
	finished = true #should we exit the loop
	min_distributions = (returns.sum / 30.0).to_i # Required Min. Distributions from 401k after retirement
	rmd_tax = tax_bracket(min_distributions)
	(0..years).each do |year|
		if (tax_bracket(salaries[year] - contributions[year]) > rmd_tax and contributions[year] < k401_limit)
			contributions[year] += 1
			finished = false
		end
	end
	if finished
		p returns.sum
		puts
		break
	end
end

p contributions
puts 

p (0..years).map { |i| ((contributions[i].to_f / salaries[i]) * 1000).to_i }
