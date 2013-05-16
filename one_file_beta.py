import sys

dict = {}
# dict is a dictionary type, just like java's hashmap, structure is key: value, value can be any type
# for instance: dict = {'ios': 1, 'android': 'google'}
# dict['ios'] is 1, dict['android'] is 'google'

# In this code, key is the frameID, value is the coordinates

with open('detect_bus.txt') as file:
# with open equivalent to file = open(xxx)
	for line in file:
		# seprate string into a list by ','
		words = line.strip().split(',')
		if len(words) > 2:
			for n in range(0, len(words)):
				if n%4==1:
					words[n] = '2, ' + str(words[n])
				else:
					pass
			if words[0] in dict:
				dict[words[0]] = dict[words[0]] + ', ' + ', '.join(x for x in words[1:])
			else:
				dict[words[0]] = ', '.join(x for x in words[1:])
				# ', '.join(x for x in words[1:]) : connect all elements of a list by ', ', words[1:] is from the second element to the end of element


with open('detect_car.txt') as file:
	for line in file:
		words = line.strip().split(',')[:21]
		if len(words) > 2:
			for n in range(0, len(words)):
				if n%4==1:
					words[n] = '3, ' + str(words[n])
				else:
					pass
			if words[0] in dict:
				dict[words[0]] = dict[words[0]] + ', ' + ', '.join(x for x in words[1:])
			else:
				dict[words[0]] = ', '.join(x for x in words[1:])

with open('detect_person.txt') as file:
	for line in file:
		words = line.strip().split(',')
		if len(words) > 2:
			for n in range(0, len(words)):
				if n%4==1:
					words[n] = '1, ' + str(words[n])
				else:
					pass
			if words[0] in dict:
				dict[words[0]] = dict[words[0]] + ', ' + ', '.join(x for x in words[1:])
			else:
				dict[words[0]] = ', '.join(x for x in words[1:])

for k in dict:
	print '<data ref="SENSOR_NAME">' + k + ', ' + dict[k] + '</data>'