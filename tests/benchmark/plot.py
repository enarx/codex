import matplotlib.pyplot as plt
import subprocess
import sys

ret = []
for prog in sys.argv[1:]:
	ret.append([[], []])
	for _ in range(10): # run 10 times
		s = subprocess.run(['time', '--format', "%e %M", 'enarx', 'deploy', prog], capture_output=True)
		if s.returncode != 0:
			print(s.stderr.decode('utf-8'))
			exit(1)
		s = s.stderr.decode('utf-8').split()
		ret[-1][0].append(float(s[0])) # time
		ret[-1][1].append(float(s[1])/1000) # memory

fig, ax = plt.subplots()
for lang, data in zip(sys.argv[1:], ret):
    ax.scatter(*data, label=lang)

ax.legend()
ax.set_xlabel('Time (s)')
ax.set_ylabel('Memory (MB)')
plt.show()
