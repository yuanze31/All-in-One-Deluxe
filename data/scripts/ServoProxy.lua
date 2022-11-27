--<Author: Brento666>--
--<Copyright: Brento666, the Netherlands, 2015>--
--<Don't redistribute: see base-language for cc>--
function Create()
	local obj = Object.Spawn("Servo", this.Pos.x, this.Pos.y)
	obj.Or.x = this.Or.x
	obj.Or.y = this.Or.y
	this.Delete()
end
