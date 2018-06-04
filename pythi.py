from cassandra.cluster import Cluster  
cluster = Cluster()  
print ("no cassandra server found ") 
if cluster is None:  
  print (" no no ")  
else:  
  print ("cassandra found") 
