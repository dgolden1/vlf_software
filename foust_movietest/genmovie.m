[x,y] = meshgrid([-pi:.01:pi],[-pi:.01:pi]);
%[x,y] = meshgrid([-pi:.1:pi],[-pi:.1:pi]);

% May need this option.  
%opengl neverselect
%opengl software

n=0;
az=-45;
az=0;
el=30;
el=0;
for t=0:.1:80;
f=sin(x.^2+y.^2-t);
%imagesc(f); caxis([-1 1])
disp(sprintf('n=%d',n));
surf(x,y,f); caxis([-1 1]); colormap(jet(256));
alpha(.7);
view(-45,30);
set(gcf, 'InvertHardCopy', 'off');
set(gcf,'Color','black'); 
set(gca,'Color','black');
set(gca,'ZColor','white'); 
set(gca,'YColor','white'); 
set(gca,'XColor','white');

set(gca,'LineWidth',2)
set(gca,'GridLineStyle','--')
set(gca,'Projection','Perspective')

pbaspect('manual');
pbaspect([1 1 .5]);

if( n == 0 )
  axis tight;
  ax = axis;

  set(gca,'CameraViewAngleMode','manual');
  set(gca,'XTickMode','manual');
  set(gca,'YTickMode','manual');
  set(gca,'ZTickMode','manual');
  set(gca,'CameraTargetMode','manual');

  viewangle = get(gca,'CameraViewAngle');
  xtck = get(gca,'XTick');
  ytck = get(gca,'YTick');
  ztck = get(gca,'ZTick');
  cameratarget = get(gca,'CameraTarget');

else
end;
  axis(ax);

  set(gca,'CameraViewAngleMode','manual');
  set(gca,'XTickMode','manual');
  set(gca,'YTickMode','manual');
  set(gca,'ZTickMode','manual');
  set(gca,'CameraTargetMode','manual');

  set(gca,'CameraViewAngle',viewangle*1.2);
  set(gca,'XTick',xtck);
  set(gca,'YTick',ytck);
  set(gca,'ZTick',ztck);
  set(gca,'CameraTarget',cameratarget);
axis off

shading interp
camorbit(az,el);

% Don't use opengl renderer for eps
%print('-depsc', sprintf('out/out%0.5d.eps',n),'-zbuffer');
%print('-depsc',sprintf('out/out%0.5d.eps',n),'-painters');
print('-dpng', '-r50', sprintf('out/out%0.5d.png',n),'-opengl');
n = n+1;
az = az + 1;
el = el + .5;
end;


