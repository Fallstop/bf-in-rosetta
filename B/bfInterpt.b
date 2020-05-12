main() {
    extrn argv;
	auto i, codeRaw, codeVec[100], bracketVec[100],inputRaw, inputs[50],inputsTemp[50], inputsLength, inputRLength, inputPointer, memory[2000], mp, mLen, c,tempArg, x, BrakLevl;

	
	printf("%d*n",argv[0]);
	if (argv[0] < 3){
		printf("Help:*n*n./a.out code~ [inputs, ~ spearated~] [Num of inputs~]*n");
		printf("It is nessory to end all args with a exclamation mark*n");
		printf("*nEG:*n    ./a.out ,++.~ 5~ 1~*n");
		return(0);
	}
	codeRaw = ",-->+.>>>+.<<<<[->[->+>+<<]>>[-<<+>>]>[->+>+<<]>>[-<<+>>]<<<<[->>>>>+<<<<<]>>>[->>+<<]>>.<<<<<<[-]>>>[-<<<+>>>]>>>[-<<<+>>>]<<<<<<<]";
	
	
	i = 1;
	while (char(argv[2],i) != '~') {
		i++;
	}
	codeVec[0] = i;
	codeVec[0] = 132;

	if (argv[0] == 3) {
		printf("Input length is required if using inputs*n");
		return(0);
	}
	if (argv[0] > 3) {
		inputRaw = argv[3];
		inputRLength = argv[4];
		inputsLength = strToNum(inputRLength);
		x = 0;
		while (x < inputsLength) inputs[x++] = 0;
		inputs = vecToNum(inputRaw,inputsLength);
		printf("Input 1 inside if statment is %d*n",inputs[0]);
	}
	printf("Input 1 outside if statment is %d*n",inputs[0]);
	
	i = 0;
	while (i<codeVec[0]) {
		codeVec[i+1] = char(codeRaw,i);
		i++;
	}
	printf("Now get ready for the real Fuck You from the compiler*n");
	printf("Input 1 little bit further is ");
	printf("%d*n",inputs[0]);
	
	printf("Matching Brackets*n");
	i = 1;
	x = 0;
	BrakLevl = 0;
	
	while(i <= codeVec[0]) {
		c = codeVec[i];
		if (c == '[') {
			BrakLevl =+ 1;
			bracketVec[i] = BrakLevl;
		}
		else if (c == ']') {
			x = 0;
			while (bracketVec[i] != BrakLevl) {
				i =- 1;
				x++;
			}
			bracketVec[i+x] = i-1;
			i =+ x;
			BrakLevl =- 1;
		}
		else {
			bracketVec[i] = 0;
		}
		i++;
	}

	printf("Running BF*n*n");
	printf("520~ in decimal is: %d*n*n",vecToNums("520~",1)[0]);
	c = vecToNums("35~634~1~3~",4);
	printf("35~634~1~3~ in decimal is: %d,%d,%d,%d*n*n",c[0],c[1],c[2],c[3]);
	
	printf("3~ in decimal is: %d*n*n",strToNums("3~"));

	i = 1;
	mp = 0;
	mLen = 0;
	memory[0] = 0;
	inputPointer = 0;
	printf("Input 1 outside if statment 20 lines down is %d*n",inputs[0]);
	while (i <= codeVec[0]) {
		printf("EXCUTING %d CHAR %c*n",i,codeVec[i]);
		if (codeVec[i] == '<') mp =- 1;
		else if (codeVec[i] == '>') {
			mp =+ 1;
			if (mp > mLen) {
				mLen =+ 1;
				memory[mp] = 0;
			}
		}
		else if (codeVec[i] == ',') {
			memory[mp] = inputs[inputPointer];
			inputPointer =+ 1;
		}
		else if (codeVec[i] == '.') printf("Output: %d*n",memory[mp]);
		else if (codeVec[i] == '+') memory[mp] =+ 1;
		else if (codeVec[i] == '-') memory[mp] =- 1;
		else if (codeVec[i] == ']') {
			if (memory[mp] != 0) {
				i = bracketVec[i];
			}
		}
		else if (codeVec[i] == '~') printf("End of code reached");


		i++;
	}
	printf("*n*nProgram finsihing normaly, i = %d, codeVec[0] = %d*n",i ,codeVec[0]);

	return(0);
}

vecToNum(string,numToExtract){
	auto result,num[50],numVec[5], i, x, c, digitStr, digitNum, numCount, y;
	c = '5';
	x = 0;
	y = 1;
	numVec[0] = 0;
	numCount = 0;
	while (numCount < numToExtract) {
		
		digitStr = char(string,x);
		digitNum = (digitStr - '0');
		if (digitStr != '~') {
			numVec[y] = digitNum;
			numVec[0] =+ 1;
			/* printf("Number Length: %d,",numVec[0]);
			printf("Digit (%c), ",digitStr);
			printf("Num: %d, ",numVec[y]);
			printf("NumVecLoc: %d*n",y); */
		} else {
			num[numCount] = 0;
			y = 0;
			i = 0;
			while (numVec[0] != 0) {
				num[numCount] =+ (numVec[i+1] * power(10,numVec[0]))/10;
				/* printf("Adding %d to the total, digit is %d*n",(numVec[i+1] * power(10,numVec[0]))/10,numVec[i+1] ); */
				numVec[0] =- 1;
				i++;
			}
			numCount =+ 1;
			numVec[0] = 0;

		}
		y++;
		x++;
	}
	
	return (num);
}

strToNum(str) {
	auto i, result;
	i = 0;
	result = (vecToNum(str,1)[0]);
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

copyVec(vec, vec2, len) {
	auto i;
	i = 0;
	while (i < len) {
		vec2[i] = vec[i];
		i++;
	}
	printf("CopyResult: %d*n",vec2[0]);
	return (0);
}