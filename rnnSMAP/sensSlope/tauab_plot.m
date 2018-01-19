function ktau = tauab_plot(usgs,varargin)
vfield = 'v';
if length(varargin)>0
    vfield = varargin{1};
end
if isfield(usgs,vfield)
    len=length(usgs);
    ktau=[];
    for i=1:1:len
        usgs(i).v=usgs(i).(vfield)
        if(length(usgs(i).v)>10)
            [taub tau h sig Z S sigma sen n senplot CIlower CIupper D Dall C3 nsigma std_dev]=ktaub([usgs(i).t,usgs(i).v],0.05,1);
            a=struct('taub',taub,'tau',tau,'h',h,'sig',sig,'Z',Z,'S',S,'sigma',sigma,'sen',sen,'n',n,'senplot',senplot,'CIlower',CIlower,'CIupper',CIupper,'D',D,'Dall',Dall,'C3',C3,'nsigma',nsigma,'std_dev',std_dev);
            ylabel(vfield)
            if isfield(usgs,'lon')
                title(['Location:',num2str(usgs(i).lon,3),' ',num2str(usgs(i).lat,3),' ','slope=',num2str(sen*365)])
                %fixFigure;
            end
%            saveas(gcf,[num2str(loc(1,i)),'_',num2str(loc(2,i)),'.fig']);
            ktau=[ktau,a];
            %clf;
            %        save([usgs(1,i).name,'mat'],'-struct','a');
        end
    end
else
    error('Field is not in sructure')
end
end
