import numpy as np
import matplotlib.pyplot as plt
import pylab

skip = 10 # how many ticks to skip

odtok_value = np.genfromtxt('Odtok.csv', usecols=(0, 1),dtype=None, delimiter = ';')
pritok_value = np.genfromtxt('Pritok.csv', usecols=(0, 1),dtype=None, delimiter = ';')
hladina_value = np.genfromtxt('VyskaHladiny.csv', usecols=(0, 1),dtype=None, delimiter = ';')
ziadana_hladina_value = np.genfromtxt('ZiadanavyskaHladiny.csv', usecols=(0, 1),dtype=None, delimiter = ';')

o = [x[0] for x in odtok_value]
p = [x[0] for x in pritok_value]
h = [x[0] for x in hladina_value]
z = [x[0] for x in ziadana_hladina_value]

o_time = [x[1] for x in odtok_value]
p_time = [x[1] for x in pritok_value]
h_time = [x[1] for x in hladina_value]
z_time = [x[1] for x in ziadana_hladina_value]

xo_axis = np.linspace(0,len(o),len(o))
xp_axis = np.linspace(0,len(p),len(p))
xh_axis = np.linspace(0,len(h),len(h))
xz_axis = np.linspace(0,len(z),len(z))

fig = plt.figure()
ax = fig.add_subplot(211) #because long ticks

ax.plot(xo_axis,odtok_value, label = 'Odtok',color = 'r')
ax.plot(xp_axis,pritok_value, label = 'Pritok',color = 'g')
ax.plot(xh_axis,hladina_value, label = 'VyskaHladiny',color = 'b')
#ax.plot(xz_axis,ziadana_hladina_value, label = 'ZiadanavyskaHladiny',color = 'k')

n = [x for x in range(0,len(o))]
n = n[0::skip]
o_time = o_time[0::skip]
pylab.xticks(n, o_time, rotation = 90)
plt.grid()
plt.legend()
plt.show()
