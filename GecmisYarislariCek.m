function GecmisYarislariCek()
global dsGecmisYarislar dsIndekslenenGecmisYarislar
%% internetten veri cekme

% 1: Adana
% 2: Ýzmir (%c4%b0zmir)
% 3: Ýstanbul (%c4%b0stanbul)
% 4: Bursa
% 5: Ankara

sehirStr = {...
    'Adana';
    '%c4%b0zmir';
    '%c4%b0stanbul';
    'Bursa';
    'Ankara';};
% Ornek csv dosyasi URL'si
% http://www.tjk.org/TR/YarisSever/Info/GetCSV/GunlukYarisSonuclari?SehirId=3&QueryParameter_Tarih=07/05/2006&Sehir=%c4%b0stanbul

% internet baglantisi var mi?
try
    % google.com'a baglanmaya calis
    fid = fopen('temp.txt','w');
    fprintf(fid,'%s',urlread('http://www.google.com'));
    fclose(fid);
    delete('temp.txt');
catch
    % baglanamiyorsak internet yok demektir.
    % google cokecek degil ya
    fclose(fid);
    error('internet baglantisi yok ki.')
end

t0 = datenum('January 1, 2008')-1;
tend = now-1;
gunNo = 0;
while true
    gunNo = gunNo + 1;
    t = t0 + gunNo;
    if (t > tend)
        % gunumuzu gecince dur.
        break;
    end
    
    [year, month, day] = datevec(t);
    tic
    for sehirId = 1:5
        % once bu yaris indekslenmis mi diye kontrol et.
        k = gecmisYarisIndeksKontrol(dsIndekslenenGecmisYarislar,...
            day,month,year,sehirStr{sehirId});
        if k
            % onceden indekslenmis. gec.
        else
            url = sprintf('http://www.tjk.org/TR/YarisSever/Info/GetCSV/GunlukYarisSonuclari?SehirId=%d&QueryParameter_Tarih=%02g/%02g/%d&Sehir=%s',...
                sehirId,day,month,year,sehirStr{sehirId});
            %         fname = [int2str(year), num2str(month,'%02g'), num2str(day,'%02g'), '-' int2str(sehirId) '.csv'];
            fname = sprintf('%d%02g%02g-%d.csv',year,month,day,sehirId);
            fname = 'temp.csv';
            fid = fopen(fname,'w');
            try
                fprintf('%s',[num2str(year), num2str(month,'%02g'), num2str(day,'%02g') ' tarihi icin ' sehirStr{sehirId} ' sehrinin yaris verileri okunuyor... ']);
                tic
                fprintf(fid,'%s',urlread(url));
                fclose(fid);
                fprintf(' okundu. %g\n',toc);
                % buraya temp.csv icindeki veriyi anlamlandiracak ve
                % veritabanina kaydedecek kod gelecek.
            catch
                fprintf('okunamadi. \n');
                try
                    fclose(fid);
                end
            end
        end
    end
end
1;