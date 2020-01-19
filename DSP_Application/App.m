function varargout = App(varargin)
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @App_OpeningFcn, ...
                       'gui_OutputFcn',  @App_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end
    % --- Executes just before App is made visible.
function App_OpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for App
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = App_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
    rec = audiorecorder(44100,16,1);
    record(rec);
    handles.rec = rec;
    handles.File = '';
    guidata(hObject,handles);
    set(handles.StartButton, 'visible', 'off');
    set(handles.StopButton, 'visible', 'on');
end

% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
    rec = handles.rec;
    stop(rec);
    y = getaudiodata(rec);			
    audiowrite('Record.wav', y, 44100);
    set(handles.StartButton, 'visible', 'on');
    set(handles.StopButton, 'visible', 'off');
    set(handles.Play1Button, 'visible', 'on');
    set(handles.PlotT1Button, 'visible', 'on');
end

% --- Executes on button press in UploadButton.
function UploadButton_Callback(hObject, eventdata, handles)
    [name, path] = uigetfile('*.wav; *.mp3', 'Select the record file');
    file = fullfile(path, name);
    handles.File = file;
    guidata(hObject,handles);
    set(handles.Play1Button, 'visible', 'on');
    set(handles.PlotT1Button, 'visible', 'on');
end

% --- Executes on button press in Play1Button.
function Play1Button_Callback(hObject, eventdata, handles)
    file = handles.File;
    if (isempty(file))
        [data, fs]=audioread('Record.wav');
    else
        [data, fs]=audioread(file);
    end
    sound(data, fs);
end

% --- Executes on button press in PlotT1Button.
function PlotT1Button_Callback(hObject, eventdata, handles)
    axes(handles.BeforeAxes);
    file = handles.File;
    if (isempty(file))
        [data, fs] = audioread('Record.wav');
    else
        [data, fs] = audioread(file);
    end
    T = 1/fs;
    L = length(data);
    t = (0:L-1)*T; 
    plot(1000*t(1:L), data(1:L), 'r');
    title('Signal in Time Domain');
    xlabel('Time(ms)');
    ylabel('X(t)');
    
    set(handles.PlotT1Button, 'visible', 'off');
    set(handles.PlotF1Button, 'visible', 'on');
end

% --- Executes on button press in PlotF1Button.
function PlotF1Button_Callback(hObject, eventdata, handles)
    axes(handles.BeforeAxes);
    file = handles.File;
    if (isempty(file))
        [data, fs] = audioread('Record.wav');
    else
        [data, fs] = audioread(file);
    end
    
    L = length(data); %l?y ra chi?u d�i c?a t�n hi?u
    NFFT = 2^nextpow2(L); %h�m nextpow2(len) cho ra gi� tr? p nh? nh?t th?a c�ng th?c 2^p>=len v� g�n NFFT=2^p
    f = fs / 2 * linspace(0, 1, NFFT/2+1); %h�m linspace(0,1,NFFT/2+1) t?o (NFFT/2+1), c�c gi� tr? c�ch ??u nhau t? 0 ??n 1
    xf = abs(fft(data, NFFT));
    %v? t�nh hi?u:
    plot(f, xf(1:NFFT/2+1), 'r');
    title('Signal in Frequency Domain');
    xlabel('Frequency(Hz)');
    ylabel('|P(f)|');

    set(handles.PlotF1Button, 'visible', 'off');
    set(handles.PlotT1Button, 'visible', 'on');
    set(handles.FilterButton, 'visible', 'on');
end

% --- Executes on button press in FilterButton.
function FilterButton_Callback(hObject, eventdata, handles)
    file = handles.File;
    if (isempty(file))
        [data,fs] = audioread('Record.wav');
    else
        [data,fs] = audioread(file);
    end
    
    n = 7; %b? l?c b?c 7
    lowFreq = 512 / (fs/2); %t?n s? m�p c?a d?i th�ng l� 512Hz
    highFreq = (2048) / (fs/2); %t?n s? m�p c?a d?i ch?n l� 2048Hz
    % Th?c hi?n l?c nhi?u b?ng b? l?c Butterworth v� t�n hi?u ra tr? v?
    % bi?n output:
    [b, a] = butter(n, [lowFreq, highFreq], 'bandpass');
    out = filter(b, a, data);
    
    if (isempty(file))
        audiowrite('Filted.wav', out, 44100);
    else
        file = strcat(file(1:end-4), '_Filted.wav');
        handles.File = file;
        guidata(hObject,handles);
        audiowrite(file, out, 44100);
    end
        
    set(handles.Play2Button, 'visible', 'on');
    set(handles.PlotT2Button, 'visible', 'on');
    set(handles.QuantiButton, 'visible', 'on');
end

% --- Executes on button press in Play2Button.
function Play2Button_Callback(hObject, eventdata, handles)
    file = handles.File;
    if (isempty(file))
        [data,fs] = audioread('Filted.wav');
    else
        [data,fs] = audioread(file);
    end
    sound(data,fs);
end

% --- Executes on button press in PlotT2Button.
function PlotT2Button_Callback(hObject, eventdata, handles)
    axes(handles.AfterAxes);
    file = handles.File;
    if (isempty(file))
        [data, fs] = audioread('Filted.wav');
    else
        [data, fs] = audioread(file);
    end
    
    T = 1/fs;
    L = length(data);
    t = (0:L-1)*T; 
    plot(1000*t(1:L), data(1:L), 'b')
    title('Signal in Time Domain');
    xlabel('Time(ms)');
    ylabel('X(t)');
    
    set(handles.PlotT2Button, 'visible', 'off');
    set(handles.PlotF2Button, 'visible', 'on');
end

% --- Executes on button press in PlotF2Button.
function PlotF2Button_Callback(hObject, eventdata, handles)
    axes(handles.AfterAxes);
    file = handles.File;
    if (isempty(file))
        [data, fs] = audioread('Filted.wav');
    else
        [data, fs] = audioread(file);
    end
    
    L = length(data);
    NFFT = 2^nextpow2(L);
    f = fs / 2 * linspace(0, 1, NFFT/2+1);
    xf = abs(fft(data, NFFT));
    plot(f, xf(1:NFFT/2+1), 'b');
    title('Signal in Frequency Domain');
    xlabel('Frequency(Hz)');
    ylabel('|P(f)|'); 

    set(handles.PlotF2Button, 'visible', 'off');
    set(handles.PlotT2Button, 'visible', 'on');
end

% --- Executes on button press in QuantiButton.
function QuantiButton_Callback(hObject, eventdata, handles)
    file = handles.File;
    if (isempty(file))
        [signal Srate nBits] = wavread('Filted.wav');
    else
        [signal Srate nBits] = wavread(file);
    end
    %Kh?o s�t t�n hi?u signal
    l = length(signal);
    k = mod(l,1024);            %??m b?o ?? d�i c?a signal l� b?i c?a 1024
    signal = signal([1:l-k],1); % Lo?i b? k ph?n t? d?
    Mp = max(signal);
    bits = 8;                   %D�ng 8 bit ?? m� h�a 1 m?u
    levels = 2^bits;            %So mau 8 bit m� h�a ???c
    step_size = (2*Mp)/levels;  %B??c nh?y cho m?i kho?ng
    codebook = [-Mp+step_size:step_size:Mp]; % S? ??i di?n cho m?i kho?ng trong ph?n partition
    partition = [-Mp+2*step_size:step_size:Mp]; %Chia t�n hi?u th�nh 256 kho?ng

    %Chia t�n hi?u th�nh c�c frame, m?i frame c� ch?a 1024 m?u
    frame = reshape(signal,1024,length(signal)/1024);
    %frame l� m?t ma tr?n c� 1024 h�ng v� length(signal)/1024 c?t
    k = length(signal)/1024;

    for i = 1:k
        sig_t = frame(:,i);%Ch?n frame th? i
        sig_comp = compressor(sig_t);%Thuc hien nen
        [index,sig_quant] = DPCM(sig_comp,codebook,partition);
        sig_enc = Encoder(index);%Chuyen c�c ch? s? index sang chu?i s? nh? ph�n
    end

    fid = fopen('BinaryCode.txt','wt'); %t?o ra file l?u .txt ?? ghi d? li?u l�n
    for i=1:size(sig_enc,1)             %duy?t t?ng d�ng k�ch th??c c?a ma tr?n d? li?u
        fprintf(fid,'%g\t',sig_enc(i,:));%ghi l�n file t?ng d�ng bit t? b? d? li?u
        fprintf(fid,'\n');               %xu?ng d�ng ?? ghi c�c bit ti?p theo
    end
    fclose(fid);                        %?�ng file k?t th�c vi?c ghi d? li?u
    open('BinaryCode.txt');
end
