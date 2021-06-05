-- affine textured rasterization
function tpoly(v,uv)
	local p0,spans=v[#v],{}
	local x0,y0,w0=p0[1],p0[2],1--p0.w
	local u0,v0=uv[#v][1]*w0,uv[#v][2]*w0
	-- ipairs is slower for small arrays
	for i=1,#v do
		local p1=v[i]
		local x1,y1,w1=p1[1],p1[2],1--p1.w
		local u1,v1=uv[i][1]*w1,uv[i][2]*w1
		local _x1,_y1,_w1,_u1,_v1=x1,y1,w1,u1,v1
		if(y0>y1) x0,y0,x1,y1,w0,w1,u0,v0,u1,v1=x1,y1,x0,y0,w1,w0,u1,v1,u0,v0
		local dy=y1-y0
		local dx,dw,du,dv=(x1-x0)/dy,(w1-w0)/dy,(u1-u0)/dy,(v1-v0)/dy
		local cy0=y0\1+1
		if(y0<0) x0-=y0*dx w0-=y0*dw u0-=y0*du v0-=y0*dv y0=0 cy0=0
		-- sub-pix shift
		local sy=cy0-y0
		x0+=sy*dx
		w0+=sy*dw
		u0+=sy*du
		v0+=sy*dv
		if(y1>127) y1=127
		for y=cy0,y1 do
			local span=spans[y]
			if span then
				--rectfill(x[1],y,x0,y,offset/16)
				
				local a,aw,au,av,b,bw,bu,bv=x0,w0,u0,v0,unpack(span)
				if(a>b) a,aw,au,av,b,bw,bu,bv=b,bw,bu,bv,a,aw,au,av
				local ca,cb=a\1+1,b\1
				if ca<=cb then
					-- perspective correct mapping
					local sa=ca-a
					local dab=b-a
					local dau,dav=(bu-au)/dab,(bv-av)/dab
					tline(ca,y,cb,y,(au+sa*dau)/aw,(av+sa*dav)/aw,dau/aw,dav/aw)
				end
			else
				spans[y]={x0,w0,u0,v0}
			end
			x0+=dx
			w0+=dw
			u0+=du
			v0+=dv
		end
		x0,y0,w0,u0,v0=_x1,_y1,_w1,_u1,_v1
	end
end