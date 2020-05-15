import subprocess
import time
import csv
RangeToDo = 500
NumToIterate = 3
csvFileName = "benchOuput.csv"
timesAll = []
timesAvg = []
i = 3
while i <= RangeToDo:
    timesAll.append([i])
    timesAvg.append([i])
    i+=1
i=0
while i < NumToIterate:
    for x,nums in enumerate(timesAll):
        print(".\\LoopCache ../example.txt "+str(nums[0]))
        start_time = time.time()
        subprocess.check_output(".\\LoopCache ../example.txt "+str(nums[0]))
        time_taken = time.time() - start_time
        timesAll[x].append(time_taken)
        
    i+=1
    
x = 0
while x < len(timesAvg):
    timesAvg[x].append(round(sum(timesAll[x][1:])/NumToIterate,5))
    x+=1

print(timesAvg)
csvFile = open(csvFileName,"w+",newline='')
csvWriter = csv.writer(csvFile)
i = 0
for row in timesAvg:
    csvWriter.writerow([row[0],row[1]])