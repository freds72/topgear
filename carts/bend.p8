pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
#include vector.lua

local track={
 {32,32},
 {64,32},
 {96,64},
 {96,96}}
local tracki=0
function _update()
 if(btnp(4)) tracki=(tracki+1)%#track

 local dx,dy=0,0
 if(btn(0)) dx=-1
 if(btn(1)) dx=1
 if(btn(2)) dy=-1
 if(btn(3)) dy=1
 local p0=track[tracki+1]
 p0[1]+=dx
 p0[2]+=dy
 
	local p0=track[#track]
	for i=1,#track do
		local p1=track[i]		

	 -- update normal
 	local u=v_normz(make_v(p0,p1))
		local v=v_normz({u[2],-u[1]})
		p0.u=u	
		p0.v=v
		
		--
		p0=p1
	end
end

function intersect(p1, p2, p3, p4)
	local eps = 0.001

	local denom =(p4[2]-p3[2])*(p2[1]-p1[1])-(p4[1]-p3[1])*(p2[2]-p1[2])
	local numera=(p4[1]-p3[1])*(p1[2]-p3[2])-(p4[2]-p3[2])*(p1[1]-p3[1])
	local numerb=(p2[1]-p1[1])*(p1[2]-p3[2])-(p2[2]-p1[2])*(p1[1]-p3[1])

	if (-eps < numera and numera < eps) and
     (-eps < numerb and numerb < eps) and
     (-eps < denom  and denom  < eps) then
			-- parallel
			return 2,{(p1[1]+p2[1])*0.5,(p1[2]+p2[2])*0.5}
	end

	-- no intersection
	if(-eps < denom and denom  < eps) return

	local mua = numera / denom
	local mub = numerb / denom
	local out={
		p1[1] + mua * (p2[1] - p1[1]),
		p1[2] + mua * (p2[2] - p1[2])}
	local out1 = mua < 0 or mua > 1
	local out2 = mub < 0 or mub > 1

	local outcode=1
	if out1 and out2 then
		outcode=5  --the intersection lies outside both segments
	elseif out1 then
		outcode=3 --the intersection lies outside segment 1
	elseif out2 then
		outcode=4 --the intersection lies outside segment 2
	end
		
	return outcode,out --the intersection lies inside both segments
end

function _draw()
	cls()	
	local inner,outer={},{}
	local n=#track
	for i=0,n-1 do
		local t1,t2,t3=track[((i-1)%n)+1],track[(i%n)+1],track[((i+1)%n)+1]
		line(t1[1],t1[2],t2[1],t2[2],7)
		
		-- credits:
		-- https://www.codeproject.com/Articles/226569/Drawing-polylines-by-tessellation
		-- side lines
		local p1,p2=v_add(t1,t1.v,8),v_add(t2,t1.v,8)
		local p3,p4=v_add(t2,t2.v,8),v_add(t3,t2.v,8)
		-- line(p1[1],p1[2],p2[1],p2[2],1)
		local res,out=intersect(p1,p2,p3,p4)
		if out then
			local side,right_side,left_side=1,inner,outer
			if res==1 then
				side,right_side,left_side=-1,outer,inner
			end
			add(right_side,v_add(t2,t1.v,side*8)) -- p2
			add(right_side,v_add(t2,t2.v,side*8)) -- p3
			-- get the "opposite" point		
			out=v_add(t2,make_v(t2,out),-side) 
			pset(out[1],out[2],8) 
			add(left_side,out) 
			print(res,out[1],out[2]-8,7)
		end			

	end
	
	n=#outer
	for i=1,#outer do
		local p0,p1=outer[i%n+1],outer[i]
		line(p0[1],p0[2],p1[1],p1[2],1)
	end
	n=#inner
	for i=1,#inner do
		local p0,p1=inner[i%n+1],inner[i]
		line(p0[1],p0[2],p1[1],p1[2],1)
	end

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
