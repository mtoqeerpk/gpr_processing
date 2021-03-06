function [snapshot,z,x]=afd_snap_acoustic2(delx,delt,velocity,logdensity,snap1,snap2,spatial_order,boundary)
% AFD_SNAP ... take one finite difference time step
%
% [snapshot,z,x]=afd_snap_acoustic(delx,delt,velocity,logdensity,snap1,snap2,spatial_order,boundary)
%
% AFD_SNAP_ACOUSTIC propogates a wavefield forward in depth by 
% one time step.  Two input matrices of the wavefield, one at 
% time=0-delt and one at time=0, are used in a finite 
% difference algorithm to propogate the wavefield.  The 
% finite difference algorithm can be calculated with a 
% five approximation to the spatial_order operator.  The snapshot
% of this propagated wavefield is returned. Note that the velocity 
% and grid spacing must fulfill the equation max(velocity)*delt/delx
% > 0.7 for the model to be stable. This condition usually results in
% snap1 and snap2 being identical. Current implementation of absorbing
% boundary conditions assumes no logdensity contrast at boundary.
%
% delx = the horizontal AND vertical bin spacing in consistent units
% delt = time interval in seconds
% velocity = the input velocity matrix in consisnent units
%          = has a size of floor(zmax/delx)+1 by floor(xmax/delx)+1
% logdensity = the input logdensity matrix in consisnent units. This is the
%               natural logarithm of the normal density.
%          = has a size of floor(zmax/delx)+1 by floor(xmax/delx)+1
% snap1 = the wavefield at time=0 - delt (same size as velocity matrix)
%        = will be based on the source array desired i.e. the position
%          of the sources will be one, and the rest of the positions
%          will be zero
% snap2 = the wavefield at time = 0 (same size as velocity matrix)
% spatial_order = order of the spatial approximation
%           = 1 is a second order approximation
%           = 2 is a fourth order approximation
% boundary = indicate whether all sides of the matrix are absorbing
%          = 0 indicates that no absorbing boundaries are desired
%          = 1 indicates all four sides are absorbing
%          = 2 choses three sides to be absorbing, and the top one not to be
%             this enables sources to be put on the surface
%
% snapshot = the wavefield propagated forward one time interval
%            where the time interval = delt
% 
% by Carrie Youzwishen, February 1999
% extended to full acoustic wave equation by Hugh Geiger, September 2003 
%
% NOTE: It is illegal for you to use this software for a purpose other
% than non-profit education or research UNLESS you are employed by a CREWES
% Project sponsor. By using this software, you are agreeing to the terms
% detailed in this software's Matlab source file.
 
% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by 
% its author (identified above) and the CREWES Project.  The CREWES 
% project may be contacted via email at:  crewesinfo@crewes.org
% 
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) Use of this SOFTWARE by any for-profit commercial organization is
%    expressly forbidden unless said organization is a CREWES Project
%    Sponsor.
%
% 2) A CREWES Project sponsor may use this SOFTWARE under the terms of the 
%    CREWES Project Sponsorship agreement.
%
% 3) A student or employee of a non-profit educational institution may 
%    use this SOFTWARE subject to the following terms and conditions:
%    - this SOFTWARE is for teaching or research purposes only.
%    - this SOFTWARE may be distributed to other students or researchers 
%      provided that these license terms are included.
%    - reselling the SOFTWARE, or including it or any portion of it, in any
%      software that will be resold is expressly forbidden.
%    - transfering the SOFTWARE in any form to a commercial firm or any 
%      other for-profit organization is expressly forbidden.
%
% END TERMS OF USE LICENSE

[nz,nx]=size(snap1);
if(prod(double(size(snap1)~=size(snap2))))
	error('snap1 and snap2 must be the same size');
end
xmax=(nx-1)*delx;
zmax=(nz-1)*delx;

x=0:delx:xmax;
z=(0:delx:zmax)';
if(spatial_order==1)
    %second order
    snapshot=velocity.^2.*delt^2.*spatial_derivs_order2(snap2,logdensity,delx) + 2*snap2 - snap1;
else
    %fourth order
    snapshot=velocity.^2.*delt^2.*spatial_derivs_order4(snap2,logdensity,delx) + 2*snap2 - snap1;
end
	
%prepare for absorbing bc's by zeroing outer 1 row and column
if boundary == 1
   snapshot(1,:)=zeros(1,nx);
   snapshot(nz,:)=zeros(1,nx);
   snapshot(:,1)=zeros(nz,1);
   snapshot(:,nx)=zeros(nz,1);
else
   %zero the first row of the wavefield for free surface
   % valid with boundary = 0 or 2
%   snapshot(1,:)=zeros(1,nx);
   snapshot(nz,:)=zeros(1,nx);
   snapshot(:,1)=zeros(nz,1);
   snapshot(:,nx)=zeros(nz,1);
end

if(boundary)
   [snapshot]=afd_bc_outer(delx,delt,velocity,snap1,snap2,snapshot,boundary);
end  


