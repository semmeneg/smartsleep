function [x,Fs,Start_date,Start_time,Label,Dimension,Coef,Nmb_chans,N] = readedf_2(fname,ch,t1,t2)

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
if nargin<2;ch='***';end
if nargin<3;t1=0;end
if nargin<4;t2=[];end
%oldfname=fname;
%[NoOfChanels,labels,recordLength] = readedfheader(fname);
%labels
% Check between file name / file handle
if length(fname)==1
    fid = fname;
elseif length(fname)==0

    [fname,pname]=uigetfile('*.rec;*.edf','Select European Data Format file');
    fname = [pname fname];
    fid = fopen(fname,'r');
else
    fid = fopen(fname,'r');
end
if fid<0
    disp('Cannot open file !');
    return;
end
if isstr(ch)

    [Nmb_chans,Label,recordLength] = readedfheader_1(fname);
    match_ch = [];
    for i=1:Nmb_chans
        if strncmp(lower(ch),lower(setstr(Label(i,:))),length(ch))
            match_ch = [match_ch i-1];
        end
    end
    if length(match_ch)>1
        fprintf('Matching channels in the given EDF file:\n');
        for i=1:length(match_ch)
            fprintf('Channel %d:\t%s\n',match_ch(i),setstr(Label(match_ch(i)+1,:)));
        end
        error('Only one channel should be given!');
    elseif length(match_ch)==0

        [selectedIndex, selectedString]  = lbox(Label,'Double Click to Choose a Channel');
        if selectedIndex <= 0
            error('Open EDF Cancelled');
            return;
        else
            ch  =selectedIndex-1;%selectedIndex starts at 1
        end

    else
        ch = match_ch;

    end
    if length(fname)>1	% fname is not fid in function call; needs re-opening as edfhdr closes the file
        fid = fopen(fname,'r');
    end
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


fseek(fid,current+ch*16,-1);
Label      = setstr(fread(fid,16,'char')');
fseek(fid,current+Nmb_chans*16+Nmb_chans*80,-1);

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
Data_rec = sum(Nmb_smps)*2; % *2 cos 2 bytes per sample
N = Blck_size*(pos1-pos0-Hdr_size)/Data_rec;

% Transform the start and end times to seconds if necessary
if max(size(t1))>1
    t1 = hour2sec(t1) - hour2sec(Start_time);
end
if length(t2)>1
    t2 = hour2sec(t2) - hour2sec(Start_time);
elseif isempty(t2)
    t2 = Blck_size;
end
if t2>N | isinf(t2);t2=N;end

% Then read the data
Fs = Nmb_smps(ch+1)/Blck_size;
x  = zeros(min([round(Fs*(t2-t1)) ceil(N*Fs)]),1);
len = length(x);
Skip = Data_rec-Nmb_smps(ch+1)*2;
Blck_1 = fix(t1/Blck_size);		% 1st data block number
block1 = Data_rec*Blck_1;
Blck_N = fix(t2/Blck_size);		% Last data block number

% 1st data block
if (fseek(fid,Hdr_size+block1,-1)<0)
    x=[];return;
end
Blck_cnt = Blck_1;
if ch~=0
    Skip_1 = sum(Nmb_smps(1:ch))*2;
else
    Skip_1 = 0;
end
offset = round(rem(t1,Blck_size)*Fs)*2;
if (fseek(fid,offset + Skip_1,0)<0)
    x=[];return;
end
if Blck_1==Blck_N 			% Read only within one block
    n2 = round(rem(t2,Blck_size)*Fs) - offset/2;
else					% Read at least within two blocks
    n2 = Nmb_smps(ch+1) - offset/2;
end
x(1:n2) = fread(fid,n2,'int16');
% Next data blocks
while (Blck_cnt<Blck_N-1)
    Blck_cnt = Blck_cnt+1;
    n1 = n2+1;
    n2 = n1+Nmb_smps(ch+1)-1;
    if (fseek(fid,Skip,0)==0)
        x_tmp = fread(fid,Nmb_smps(ch+1),'int16');
        if ~isempty(x_tmp);x(n1:n2) = x_tmp;end
    else
        break;
    end
end
% Final data block
if Blck_1 ~= Blck_N
    fseek(fid,Skip,0);
    pos0=ftell(fid);
    fseek(fid,0,'eof');
    pos1=ftell(fid);
    N_left = Blck_size*(pos1-pos0)/Data_rec;
    fseek(fid,pos0,'bof');
    n1 = n2+1;
    offset = round(rem(t2,Blck_size)*Fs);
    if offset>0
        n2 = n1 + offset -1;
        x_tmp = fread(fid,offset,'int16');
        if length(x_tmp)==offset;x(n1:n2) = x_tmp;end
    end
end

% Finally, scale the signal
a = polyfit([Dig_min Dig_max],[Phys_min Phys_max],1);
x = x*a(1)+a(2);

% Close file if file name is used instead of file handle
if length(fname)>1
    fclose(fid);
end