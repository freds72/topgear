function lerp(a,b,t)
	return a*(1-t)+b*t
end

function v_scale(a,scale)
	a[1]*=scale
	a[2]*=scale
end

function v_len(a)
  local x,y=abs(a[1]),abs(a[2])
  if(x>y) return x*sqrt((y/x)*(y/x)+1)
  return y*sqrt((x/y)*(x/y)+1) 
end 

function v_normz(a)
 local d=v_len(a)
 return {a[1]/d,a[2]/d},d
end

function v_add(a,b,scale)
	scale=scale or 1
 return {
  a[1]+scale*b[1],
  a[2]+scale*b[2]}
end

function make_v(a,b)
  return {
    b[1]-a[1],
    b[2]-a[2]
  }
end

function v_dot(a,b)
  return a[1]*b[1]+a[2]*b[2]
end