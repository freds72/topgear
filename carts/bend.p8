pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
#include vector.lua
#include poly.lua

function make_tex(mx,my,mw,mh)
	return my<<8|mx|mh>>8|mw>>16
end

local track={
 {32,32,r=8,tex=make_tex(0,0,8,4)},
 {64,32,r=8,tex=make_tex(0,0,8,4)},
 {96,64,r=8,tex=make_tex(0,0,8,4)},
 {96,96,r=8,tex=make_tex(0,0,8,4)}}
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
		local u,len=v_normz(make_v(p0,p1))
		local v=v_normz({u[2],-u[1]})
		p0.u=u	
		p0.v=v		
		p0.len=len
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
	local faces={}
	for i=0,n-1 do
		local t1,t2,t3=track[((i-1)%n)+1],track[(i%n)+1],track[((i+1)%n)+1]
		fillp(0xa5a5)
		line(t1[1],t1[2],t2[1],t2[2],0x57)
		fillp()
		-- credits:
		-- https://www.codeproject.com/Articles/226569/Drawing-polylines-by-tessellation
		-- side lines
		local p1,p2=v_add(t1,t1.v,t1.r),v_add(t2,t1.v,t1.r)
		local p3,p4=v_add(t2,t2.v,t2.r),v_add(t3,t2.v,t2.r)
		-- line(p1[1],p1[2],p2[1],p2[2],1)
		local res,out=intersect(p1,p2,p3,p4)
		if out then
			local side,right_side,left_side=1,inner,outer
			-- straight line
			if res==2 then
				out=v_add(t2,t1.v,-t1.r)
				if i>0 then
					local lastr=right_side[#right_side]
					local l=v_len(make_v(lastr,p2))
					add(faces,{p2,out,left_side[#left_side],lastr,tex=t1.tex,uv={
						{0,l},
						{t1.r+1,l},
						{t1.r+1,0},
						{0,0}
					}})
				end				
				add(right_side,p2)
				add(left_side,out)
			else
				if res==1 then
					side,right_side,left_side=-1,outer,inner
				end
				p2=v_add(t2,t1.v,side*t1.r)
				p3=v_add(t2,t2.v,side*t2.r)
				-- get the "opposite" point		
				out=v_add(t2,make_v(t2,out),-side) 
				-- get caps
				local out_2=v_add(out,t1.v,2*side*t1.r)
				local out_3=v_add(out,t2.v,2*side*t2.r)

				if i>0 then
					local lastr=right_side[#right_side]
					local l=v_len(make_v(lastr,out_2))

					add(faces,{out_2,out,left_side[#left_side],lastr,tex=t1.tex,uv={
						{0,l},
						{t1.r+1,l},
						{t1.r+1,0},
						{0,0}
					}})
				end			
				-- inner slice
				if side==1 then
					add(faces,{out,out_3,p3,p2,out_2})
				else
					add(faces,{out,out_2,p2,p3,out_3})
				end				
				add(right_side,out_2) -- out cap
				add(right_side,p2) -- p2
				add(right_side,p3) -- p3 (bevel)
				add(right_side,out_3) -- out cap
				add(left_side,out) 
			end
		end		
	end
	if #inner>1 and #outer>1 then
		add(faces,{inner[1],outer[1],outer[#outer],inner[#inner]})
	end	
	
	n=#outer
	for i=1,n do
		local p0,p1=outer[i%n+1],outer[i]
		line(p0[1],p0[2],p1[1],p1[2],1)
	end
	n=#inner
	for i=1,n do
		local p0,p1=inner[i%n+1],inner[i]
		line(p0[1],p0[2],p1[1],p1[2],1)
	end

	for _,p in pairs(faces) do
		n=#p
		for i=1,n do
			local p0,p1=p[i%n+1],p[i]
			line(p0[1],p0[2],p1[1],p1[2],9)
		end
		-- 
		if p.uv then
			poke4(0x5f38,p.tex)	
			tpoly(p,p.uv)
		end
	end
end

function _init()
	palt(0,false)
end

__gfx__
00000000666666666666666666666f6336f6666633333333bbbbbbbb444444449999999900000000000000000000000000000000000000000000000000000000
00000000666666666666666666666f6336f6666633333333bbbbbbbb444444449999999900000000000000000000000000000000000000000000000000000000
00700700666666666667766666666f6336f6666633333333bbbbbbbb444444449999999900000000000000000000000000000000000000000000000000000000
00077000666666666667766666666f6336f6666633333333bbbbbbbb444444449999999900000000000000000000000000000000000000000000000000000000
00077000666666666667766666666f6336f6666633333333bbbbbbbb444444449999999900000000000000000000000000000000000000000000000000000000
00700700666666666667766666666f6336f6666633333333bbbbbbbb444444449999999900000000000000000000000000000000000000000000000000000000
00000000666666666667766666666f6336f6666633333333bbbbbbbb444444449999999900000000000000000000000000000000000000000000000000000000
00000000666666666666666666666f6336f6666633333333bbbbbbbb444444449999999900000000000000000000000000000000000000000000000000000000
__map__
0506070402030805060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0605080402030706050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0506070402030805060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0605080402030706050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
