pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- credits:
-- https://www.gamasutra.com/blogs/gustavomaciel/20131229/207833/generating_procedural_racetracks.php
local pts,track={},{}
function _init()
	for i=1,5+rnd(2) do
		add(pts,{rnd(128),rnd(128)})
	end
	local cvx=hull(pts)
	-- go over pairs, add turns as needed
	local p0=cvx[#cvx]
 for _,p1 in ipairs(cvx) do
		if rnd()>0.5 then
			-- find normal
			local n=v_normz(make_v(p0,p1))
			-- ortho
			n={-n[2],n[1]}
			add(track,v_add(v_mid(p0,p1),n,rnd(8)-16))
		end
		add(track,p1)
		p0=p1
	end
	track=smooth(track,4)
	
end	

function _draw()
 cls()
	local p0=track[#track]
 for _,p1 in ipairs(track) do
 	line(p0[1],p0[2],p1[1],p1[2],1)
 	p0=p1
 end

 for _,p in pairs(track) do
  pset(p[1],p[2],7)
 end

end

-->8
-- credits: https://gist.github.com/sixfingers/ee5c1dce72206edc5a42b3246a52ce2e
function hull(points)
    local p = #points

    local cross = function(p, q, r)
      return (q[2] - p[2]) * (r[1] - q[1]) - (q[1] - p[1]) * (r[2] - q[2])
    end

    sort(points, function(a, b)
     return a[1] == b[1] and a[2] > b[2] or a[1] > b[1]
    end)

    local lower = {}
    for i = 1, p do
        while (#lower >= 2 and cross(lower[#lower - 1], lower[#lower], points[i]) <= 0) do
            deli(lower, #lower)
        end

        add(lower, points[i])
    end

    local upper = {}
    for i = p, 1, -1 do
        while (#upper >= 2 and cross(upper[#upper - 1], upper[#upper], points[i]) <= 0) do
            deli(upper, #upper)
        end

        add(upper, points[i])
    end

    deli(upper, #upper)
    deli(lower, #lower)
    for _, point in ipairs(lower) do
        add(upper, point)
    end

    return upper
end
-->8
-- sort
-- https://github.com/morgan3d/misc/tree/master/p8sort
-- 
function sort(data,fn)
	local n = #data 
	if(n<2) return
	
	-- form a max heap
	for i = n\2+1, 1, -1 do
	 -- m is the index of the max child
	 local parent, value, m = i, data[i], i + i
	 local key = value 
	 
	 while m <= n do
	  -- find the max child
	  if ((m < n) and fn(data[m+1],data[m])) m += 1
	  local mval = data[m]
	  if (fn(key,mval)) break
	  data[parent] = mval
	  parent = m
	  m += m
	 end
	 data[parent] = value
	end 
   
	-- read out the values,
	-- restoring the heap property
	-- after each step
	for i = n, 2, -1 do
	 -- swap root with last
	 local value = data[i]
	 data[i], data[1] = data[1], value
   
	 -- restore the heap
	 local parent, terminate, m = 1, i - 1, 2
	 local key = value 
	 
	 while m <= terminate do
	  local mval = data[m]
	  local mkey = mval
	  if (m < terminate) and fn(data[m+1],mkey) then
	   m += 1
	   mval = data[m]
	   mkey = mval
	  end
	  if (fn(key,mkey)) break
	  data[parent] = mval
	  parent = m
	  m += m
	 end  
	 
	 data[parent] = value
	end
end
-->8
function make_v(a,b)
 return {
 	b[1]-a[1],
 	b[2]-a[2]
 }
end

function v_normz(a)
 local x,y=a[1],a[2]
 local d=sqrt(x*x+y*y)
 return {x/d,y/d},d
end

function v_add(a,b,scale)
	scale=scale or 1
 return {
  a[1]+scale*b[1],
  a[2]+scale*b[2]}
end

function v_mid(a,b)
 return {
  (a[1]+b[1])>>1,
  (a[2]+b[2])>>1}
end
-->8
function smooth( points, steps)

	if #points < 3 then
		return points
	end

	local steps = steps or 5

	local spline = {}
	local count = #points - 1
	local p0, p1, p2, p3

	for i = 1, count do

		if i == 1 then
			p0, p1, p2, p3 = points[i], points[i], points[i + 1], points[i + 2]
		elseif i == count then
			p0, p1, p2, p3 = points[#points - 2], points[#points - 1], points[#points], points[#points]
		else
			p0, p1, p2, p3 = points[i - 1], points[i], points[i + 1], points[i + 2]
		end	

		for t = 0, 1, 1 / steps do
			local x = 0.5*((2*p1[1])+(p2[1]-p0[1])*t+(2*p0[1]-5*p1[1]+4*p2[1]-p3[1])*t*t+(3*p1[1]-p0[1]-3*p2[1]+p3[1])*t*t*t)
			local y = 0.5*((2*p1[2])+(p2[2]-p0[2])*t+(2*p0[2]-5*p1[2]+4*p2[2]-p3[2])*t*t+(3*p1[2]-p0[2]-3*p2[2]+p3[2])*t*t*t)

			--prevent duplicate entries
			if not(#spline > 0 and spline[#spline][1] == x and spline[#spline][2] == y) then
				add( spline , { x , y } )				
			end				
		end
	end	
	return spline
end
