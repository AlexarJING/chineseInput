local input={}
input.caractorLibPath="caractorLib"
input.lib=require(input.caractorLibPath)

input.enable=false
input.map={}
input.map_user={}
input.select={}
input.selected=""
input.mapColor={0,255,0,255}
input.selectColor={255,255,0,255}
input.rt=""
input.pageNum=10
input.sleft=1
input.sright=input.sleft+input.pageNum-1
input.userKeys=0
input.caret=1
function input:update(key)
	if not self.enable then return end
	if key==" " and #self.select==0 then --如果没有选字框则弹出选字框
		self:match(self.caret)
		return
	end
	if key==" " and #self.select~=0 then  --如果有选字框则选择已选字
		--self.rt=self.rt .. self.select[input.sleft]
		
		for i=1,self.userKeys do
			table.remove(self.map_user,self.caret)
		end
		table.insert(self.map_user,self.caret,self.select[input.sleft])
		self.select={}
		self.caret=self.caret+1
		self:match(self.caret)
		return
	end

	if key:byte()>=48 and key:byte()<=57 and #self.select~=0 then
		local number=key:byte()-48
		if number==0 then number=10 end
		--self.rt=self.rt .. self.select[input.sleft+number-1]
		for i=1,self.userKeys do
			table.remove(self.map_user,self.caret)
		end
		table.insert(self.map_user,self.caret,self.select[input.sleft+number-1])
		self.select={}
		self.caret=self.caret+1
		self:match(self.caret)
		return
	end

	if key=="backspace" and #self.select==0 and #self.map~=0 then --如果没有选字框则删除输入字符
		if self.map_user[#self.map_user]:len()==3 then self.caret=self.caret-1 end
		table.remove(self.map, #self.map)
		table.remove(self.map_user, #self.map_user)
		return
	end
	if key=="backspace" and #self.select~=0 then --如果有选字框则取消选字
		self.select={}
		self.map_user={}
		for k,v in pairs(self.map) do
			self.map_user[k]=v
		end
		self.caret=1
		return
	end
	if key:len()==1 and key:byte()<=126 and key:byte()>=32 and #self.select==0 then
		table.insert(self.map, key)
		table.insert(self.map_user,key)
		--self:match(self.caret)
		return
	end
	if key=="return" then
		local map=""
		for k,v in pairs(self.map_user) do
			map=map..v
		end
		self.rt=self.rt..map
		self.select={}
		self.map_user={}
		self.map={}
		self.caret=1
		self.sleft=1
		input.sright=input.sleft+input.pageNum-1
		return
	end
	if (key=="pageup" or key=="pagedown") and #self.select~=0 then
		local max=#self.select
		if key=="pagedown" then
			if self.sleft+self.pageNum<max then
				self.sleft=self.sleft+self.pageNum
				self.sright=self.sright+self.pageNum
			end
		else
			if self.sleft-self.pageNum>0 then
				self.sleft=self.sleft-self.pageNum
				self.sright=self.sright-self.pageNum
			end
		end
		return
	end
end

function input:match(from)
	from=from or 0
	local text=""
	local selectMap=nil
	local found=false
	local function cMatch(str)
		for k,v in pairs(self.lib) do
			if str==k then
				self.userKeys=str:len()
				return v
			end
		end
	end

	for k,v in pairs(self.map_user) do
		if k>=from then
			text=text..v
			selectMap=cMatch(text)
			if selectMap~=nil then
				self.select={}
				for i=1,selectMap:len()/3 do
					table.insert(self.select, selectMap:sub(i*3-2,i*3))
				end
				found=true
			end
			if found==true and selectMap==nil then
				break
			end
		end
	end
	self.sleft=1
	self.sright=self.sleft+self.pageNum-1
end

function input:draw()
	local h = love.graphics.getHeight()
	
	if #self.map_user~=0 then
		love.graphics.setColor(unpack(self.mapColor))
		local map=""
		for i=1,#self.map_user do
			map=map..self.map_user[i]
		end
		love.graphics.print(map, 10, h-32)
	end
	
	if #self.select~=0 then
		love.graphics.setColor(unpack(self.mapColor))
		local select=""
		for i=self.sleft,self.sright do
			if not self.select[i] then break end
			select=select.." "..tostring(i-self.sleft+1).."."..self.select[i]
		end
		love.graphics.print(select, 10, h-16)
	end
	
	love.graphics.print(self.rt, 10,10)
end

return input