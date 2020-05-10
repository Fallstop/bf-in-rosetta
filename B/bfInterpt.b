main() {
    extrn argv;
	auto i, codeRaw, codeVec[100],inputRaw, inputsRawLength,inputs, inputPointer, memory[2000], mp, mLen, c,tempArg,x;

	
	printf("%d*n",argv[0]);
	if (argv[0] < 3){
		printf("Help:*n    ./a.out code code length [inputs, comma spearated] [inputs length]*n");
		printf("EG:*n    ./a.out ,++. 4 5, 1");
		return(0);
	}
	codeRaw = argv[2];
	codeVec[0] = 0;
	codeVec[0] = 5;

	if (argv[0] == 4) {
		printf("Input length is required if using inputs*n");
		return(0);
	}
	
	if (argv[0] > 4) {
		inputRaw = argv[4];
		inputRawLength = argv[5];
	}
	
	
	i = 0;
	while (i<codeVec[0]) {
		codeVec[i+1] = char(codeRaw,i);
		i++;
	}
	printf("Running BF*n*n");
	printf("52 in decimal is: %d*n*n",vecToNums("52,",1)[1]);
	printf("35 in decimal is: %d*n*n",vecToNums("35,",1)[1]);
	printf("34 in decimal is: %d*n*n",strToNums("34,"));

	i = 1;
	mp = 0;
	mLen = 0;
	memory[0] = 0;
	while (i < codeVec[0]) {
		printf("*n*nExcuting %d*n",i);
		if (codeVec[i] == '<') mp =- 1;
		else if (codeVec[i] == '>') mp =+ 1;
		else if (codeVec[i] == ',') {
			memory[mp] = 5;
			inputPointer =+ 1;
		}
		else if (codeVec[i] == '.') printf("Output: %d*n",memory[mp]);
		else if (codeVec[i] == '+') memory[mp] =+ 1;
		else if (codeVec[i] == '-') memory[mp] =- 1;
		else if (codeVec[i] == ']') printf("End bracket detected");
		else printf("Unexpected char");


		i++;
	}


	return(0);
}

vecToNum(string,numToExtract){
	auto result,num[100],numVec[5], i, x, c, digitStr, digitNum, numCount;
	c = '5';
	x = 0;
	numVec[0] = 0;
	numCount = 0;
	while (numCount < numToExtract) {
		
		digitStr = char(string,x);
		digitNum = (digitStr - '0');
		if (digitNum != -4) {
			numVec[x+1] = digitNum;
			numVec[0] =+ 1;
			/* printf("NumLength: %d",numVec[0]);
			printf("Digit (%c), ",digitStr);
			printf("Num: %d*n",numVec[x+1]); */
		} else {
			num[numCount] = 0;
			x = 0;
			numCount =+ 1;
			i = 0;
			while (numVec[0] != 0) {
				num[numCount] =+ (numVec[i+1] * power(10,numVec[0]))/10;
				printf("Adding %d to the total*n",(numVec[i+1] * power(10,numVec[0]))/10);
				numVec[0] =- 1;
				i++;
			}
			numVec[0] = 0;

		}
		x++;
	}

	return (num);
}

strToNum(str) {
	auto i, result;
	i = 0;
	result = (vecToNum(str,1)[1]);
	return (result);
}

power(num, power) {
	auto orgNum;
	orgNum = num;
	while (power != 1) {
		num = num*orgNum;
		power =- 1;
	}
	return (num);
}