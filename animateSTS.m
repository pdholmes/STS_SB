
datapath = 'presaved/';

% uncomment this to use local (not presaved) results
% datapath = '';

anim = Animator.STSAnimator(datapath);
mygui = STSGUI();
mygui.anim = anim;
anim = anim.AssociateAxes(mygui);
anim = anim.initializeGUI;
