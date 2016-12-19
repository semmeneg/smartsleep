function [Nmb_chans,labels,N] = readedfheader_1(fname)

%	[x,Fs,Start_date,Start_time,Label,Dimension,Coef,Nmb_chans,N] = readedf(fname,channel,t1,t2)
%
%	Reads one channel from EDF-file in given time scale. Time scale may be given as seconds from
%	the beginning of the file or in hh:mm:ss format. In hh:mm:ss format, the hours of the next days
%	are accessed by adding 24h to the true time (e.g. 25:00:00 means 01:00:00 of the day following
%	the starting date of the recording).
%
%   in:	fname		file name OR file handle (empty -> file name is asked for)
%	ch		channel number, 1st channel being 0, or channel label (default 0)
%	t1		start time (seconds from the beginning of file OR hh:mm:ss) (default 0)
%	t2		end time (seconds from the beginning of file OR hh:mm:ss) (default one block)
%
%  out:	x		signal in column vector
%	Fs		sampling frequency
%	Start_date	Date of the starting time of the recording [dd:mm:yy]
%	Start_time	Time of the beginning of the recording [hh:mm:ss]
%	Label		Signal label
%	Dimension	Signal dimension
%	Coef		Scaling coefficients [PhysMin PhysMax DigMin DigMax]
%	Nmb_chans	Number of channels in the file
%	N		data length in seconds

%	(c) Ilkka Korhonen 13.2.1996 (20.2.1996 IKo) (16.10.1997 IKo) (22.10.1997 IKo fid/fname)
%	    Juha Pärkkä 10.7.1997, IKO 11.08.1998, IKo 26.11.1998, IKo 25.01.1999, IKo 21.07.1999
%	    IKo 05.10.1999, IKo 20.10.1999 (t2 inf), IKo 03.10.2000 (ch may be string)

if nargin<1;fname=[];end


% Check between file name / file handle
if length(fname)==1
	fid = fname;
elseif length(fname)==0
	[fname,pname]=uigetfile('*.rec','Select European Data Format file');
	fname = [pname fname];
	fid = fopen(fname,'r');
else
	fid = fopen(fname,'r');
end
if fid<0
	disp('Cannot open file !');
	return;
end

% First scan the header information
	fseek(fid,168,-1); 
	Start_date = setstr(fread(fid,8,'char')');
	Start_time = setstr(fread(fid,8,'char')');
    Hdr_size   = sscanf(setstr(fread(fid,8,'char')'),'%d');
   

	fseek(fid,52,0);
	Blck_size  = sscanf(setstr(fread(fid,8,'char')'),'%d');
	Nmb_chans  = sscanf(setstr(fread(fid,4,'char')'),'%d');
	
	current = ftell(fid);
    
    for i=0:Nmb_chans-1
		fseek(fid,current+i*16,-1);
	    labels(i+1,:)      = setstr(fread(fid,16,'char')');
    end
    
	fseek(fid,current+Nmb_chans*16+Nmb_chans*80,-1);
    ch = 1;
	current = ftell(fid);
	fseek(fid,ch*8,0);
	Dimension  = setstr(fread(fid,8,'char')');
	fseek(fid,current+Nmb_chans*8,-1);

	current = ftell(fid);
	fseek(fid,ch*8,0);
	Phys_min  = sscanf(setstr(fread(fid,8,'char')'),'%f');
	fseek(fid,current+Nmb_chans*8,-1);

	current = ftell(fid);
	fseek(fid,ch*8,0);
	Phys_max  = sscanf(setstr(fread(fid,8,'char')'),'%f');
	fseek(fid,current+Nmb_chans*8,-1);

	current = ftell(fid);
	fseek(fid,ch*8,0);
	Dig_min   = sscanf(setstr(fread(fid,8,'char')'),'%d');
	fseek(fid,current+Nmb_chans*8,-1);

	current = ftell(fid);
	fseek(fid,ch*8,0);
	Dig_max   = sscanf(setstr(fread(fid,8,'char')'),'%d');
	fseek(fid,current+Nmb_chans*8+Nmb_chans*80,-1);

	Coef = [Phys_min Phys_max Dig_min Dig_max];
	
	Nmp_smps=zeros(1,Nmb_chans);
	for i=0:Nmb_chans-1
		Nmb_smps(i+1)  = sscanf(setstr(fread(fid,8,'char')'),'%d');
	end

% Calculate data length
	fseek(fid,0,'bof');
	pos0=ftell(fid);
	fseek(fid,0,'eof');
	pos1=ftell(fid);
	Data_rec = sum(Nmb_smps)*2;
	N = Blck_size*(pos1-pos0-Hdr_size)/Data_rec;


% Close file if file name is used instead of file handle
if length(fname)>1
	fclose(fid);
end