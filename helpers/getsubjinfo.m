function out = getsubjinfo(in)
out = []; 
switch in
    case 'S1/'
        out.dl = 5; %years of driver licence
        out.age = 22;
        out.frq = 3;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 2; %Less than 10000 = 1, more than 10000 = 2. 
        out.selfrate = 3; %beginner = 1, intermediate = 2, advanced = 3. 
        out.gen = 1; %1 = male, 2 = female. 
    case 'S2/'
        out.dl = 1; %years of driver licence
        out.age = 22;
        out.frq = 1;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 1; %Less than 10000 = 1, more than 10000 = 2. 
        out.selfrate = 2; %beginner = 1, intermediate = 2, advanced = 3. 
        out.gen = 1; %1 = male, 2 = female. 
    case 'S3/'
        out.dl = 6; %years of driver licence
        out.age = 28;
        out.frq = 2;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 2; %Less than 10000 = 1, more than 10000 = 2. 
        out.selfrate = 2; %beginner = 1, intermediate = 2, advanced = 3. 
        out.gen = 2; %1 = male, 2 = female. 
    case 'S4/'
        out.dl = 5; %years of driver licence
        out.age = 25;
        out.frq = 3;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 2; %Less than 10000 = 1, more than 10000 = 2. 
        out.selfrate = 2; %beginner = 1, intermediate = 2, advanced = 3. 
        out.gen = 1; %1 = male, 2 = female. 
    case 'S5/'
        out.dl = 5; %years of driver licence
        out.age = 23;
        out.frq = 1;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 1; %Less than 10000 = 1, more than 10000 = 2. 
        out.selfrate = 3; %beginner = 1, intermediate = 2, advanced = 3. 
        out.gen = 1; %1 = male, 2 = female.
    case 'S6/'
        %TO DO
        out.dl = 5; %years of driver licence
        out.age = 23;
        out.frq = 2;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 1; %Less than 10000 = 1, more than 10000 = 2. 
        out.selfrate = 2; %beginner = 1, intermediate = 2, advanced = 3. 
        out.gen = 2; %1 = male, 2 = female.
    case 'S7/'
        out.dl = 45; %years of driver licence
        out.age = 63;
        out.frq = 3;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 1; %Less than 10000 = 1, more than 10000 = 2. 
        out.selfrate = 2; %beginner = 1, intermediate = 2, advanced = 3. 
        out.gen = 1; %1 = male, 2 = female.
    case 'S8/'
        out.dl = 22; %years of driver licence
        out.age = 40;
        out.frq = 3;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 2; %Less than 10000 = 1, more than 10000 = 2. 
        out.selfrate = 3; %beginner = 1, intermediate = 2, advanced = 3. 
        out.gen = 1; %1 = male, 2 = female.
    case 'S9/'
        out.dl = 40; %years of driver licence
        out.age = 55;
        out.frq = 3;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 1; %Less than 10000 = 1, more than 10000 = 2. 
        out.selfrate = 3; %beginner = 1, intermediate = 2, advanced = 3. 
        out.gen = 2; %1 = male, 2 = female.
    case 'S10/'
        out.dl = 5; %years of driver licence
        out.age = 25;
        out.frq = 2;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 2; %Less than 10000 = 1, more than 10000 = 2. 
        out.selfrate = 2; %beginner = 1, intermediate = 2, advanced = 3. 
        out.gen = 2; %1 = male, 2 = female.
    case 'S11/'
        out.dl = 40; %years of driver licence
        out.age = 54;
        out.frq = 3;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 2; %Less than 10000 = 1, more than 10000 = 2. 
        out.selfrate = 3; %beginner = 1, intermediate = 2, advanced = 3. 
        out.gen = 2; %1 = male, 2 = female.
    case 'S12/'
        out.dl = 15; %years of driver licence
        out.age = 25;
        out.frq = 1;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 1; %Less than 10000 = 1, more than 10000 = 2. 
        out.selfrate = 2; %beginner = 1, intermediate = 2, advanced = 3.
        out.gen = 1; %1 = male, 2 = female.
    case 'S13/'
        out.dl = 9; %years of driver licence
        out.age = 25;   
        out.frq = 2;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 1; %Less than 10000 = 1, more than 10000 = 2.
        out.selfrate = 3; %beginner = 1, intermediate = 2, advanced = 3.
        out.gen = 1; %1 = male, 2 = female.
    case 'S14/'
        out.dl = 9; %years of driver licence
        out.age = 25;   
        out.frq = 3;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 1; %Less than 10000 = 1, more than 10000 = 2.
        out.selfrate = 3; %beginner = 1, intermediate = 2, advanced = 3.
        out.gen = 1; %1 = male, 2 = female.
     case 'S15/'
        out.dl = 8; %years of driver licence
        out.age = 25;   
        out.frq = 3;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 2; %Less than 10000 = 1, more than 10000 = 2.
        out.selfrate = 2; %beginner = 1, intermediate = 2, advanced = 3.
        out.gen = 2; %1 = male, 2 = female.
     case 'S16/'
        out.dl = 5; %years of driver licence
        out.age = 25;   
        out.frq = 3;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 1; %Less than 10000 = 1, more than 10000 = 2.
        out.selfrate = 2; %beginner = 1, intermediate = 2, advanced = 3.
        out.gen = 1; %1 = male, 2 = female.
     case 'S17/'
        out.dl = 9; %years of driver licence
        out.age = 25;   
        out.frq = 3;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 2; %Less than 10000 = 1, more than 10000 = 2.
        out.selfrate = 3; %beginner = 1, intermediate = 2, advanced = 3.
        out.gen = 1; %1 = male, 2 = female.
    case 'S18/'
        out.dl = 7; %years of driver licence
        out.age = 25;   
        out.frq = 3;  %1=rarely (less than once a month),2= occasionaly (once a week),3= frequently (more than 3 times a week)
        out.mlg = 2; %Less than 10000 = 1, more than 10000 = 2.
        out.selfrate = 3; %beginner = 1, intermediate = 2, advanced = 3.
        out.gen = 1; %1 = male, 2 = female.
end

end