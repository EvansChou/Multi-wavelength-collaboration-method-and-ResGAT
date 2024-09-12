clear all
 % 未知数：center_x, center_y, a, b, d, u, v
    l=-4.33009999999999984E+00;
% phi1=[59.2052729527645,59.1904034809597,59.1639179523274];
% phi2=[59.4719316006061,59.4572904870246,59.4312093976835];
% k1=tan(phi1/180*pi);
% k2=tan(phi2/180*pi);
%     k1=[0.518065135,0.518678093,0.518989043];%2.5
    
    k1=[0.542573389,0.543168455,0.543500138];%2.6
    
  k2=[0.566994364,0.567587906,0.567899174];%2.7
%     
%   k2=[0.591358333,0.591954992,0.592272625];%2.8
% 
%   k2=[0.615622976,0.616236112,0.616527442];%2.9


    y11=get_y(k1(1),l,0.405);
    y21=get_y(k1(2),l,0.520);
    y31=get_y(k1(3),l,0.635);

 
    y12=get_y2(k2(1),l,0.405);
    y22=get_y2(k2(2),l,0.520);
    y32=get_y2(k2(3),l,0.635);

 syms    d  ;

%%
    s(1)=y21-y11;
    s(2)=y11-y31;
    s(3)=y21-y31;
    s(4)=y12-y22;
    s(5)= y12-y32;
    s(6)=y22-y32;
    s(7)=d-( y12-y11);
    s(8)=d-(y22-y21);
    s(9)= d-(y32-y31);
    s(10) =d-( y12-y11)+d-(y22-y21)+d-(y32-y31);
    
F1=char(s(1));
F2=char(s(2));
F3=char(s(3));
F4=char(s(4));
F5=char(s(5));
F6=char(s(6));
F7=char(s(7));
F8=char(s(8));
F9=char(s(9));
F10=char(s(10));

%     [F1,F2,F3,F4,F5,F6,F7,F8,F9,F10]=s;

fileID=fopen('1.txt','w');
fprintf(3,'F1=' );
fprintf(3,F1);
fprintf(3,';\n');

fprintf(3,'F2=' );
fprintf(3,F2);
fprintf(3,';\n');

fprintf(3,'F3=' );
fprintf(3,F3);
fprintf(3,';\n');

fprintf(3,'F4=' );
fprintf(3,F4);
fprintf(3,';\n');


fprintf(3,'F5=' );
fprintf(3,F5);
fprintf(3,';\n');

fprintf(3,'F6=' );
fprintf(3,F6);
fprintf(3,';\n');

fprintf(3,'F7=' );
fprintf(3,F7);
fprintf(3,';\n');

fprintf(3,'F8=' );
fprintf(3,F8);
fprintf(3,';\n');


fprintf(3,'F9=' );
fprintf(3,F9);
fprintf(3,';\n');

fprintf(3,'F10=' );
fprintf(3,F10);
fprintf(3,';\n');
fclose(3);
