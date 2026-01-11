--Egyptian God Slime - Eternal
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,
		aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA),
		s.matfilter
	)

	-- Name becomes "Egyptian God Slime"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(42166000)
	c:RegisterEffect(e0)
	-- Name becomes "Egyptian God Slime" (in Extra Deck)
	local e0b=e0:Clone()
	e0b:SetRange(LOCATION_EXTRA)
	c:RegisterEffect(e0b)

	-- Alternative Special Summon (Tribute)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)

	-- Triple Tribute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRIPLE_TRIBUTE)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	-- Cannot be destroyed by battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)

	-- Battle target protection
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(s.tglimit)
	c:RegisterEffect(e4)

	-- Effect target protection
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.tglimit)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)

	-------------------------------------------------
	-- Equip opponent monster
	-------------------------------------------------
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_EQUIP)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCountLimit(1,id)
	e6:SetCondition(s.eqcon)
	e6:SetTarget(s.eqtg)
	e6:SetOperation(s.eqop)
	c:RegisterEffect(e6)

	aux.AddEREquipLimit(
		c,
		s.eqcon,
		function(ec,_,tp) return ec:IsControler(1-tp) end,
		s.equipop,
		e6
	)

	-------------------------------------------------
	-- Destroy equipped monster → inflict damage
	-------------------------------------------------
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,{id,1})
	e7:SetCondition(s.dmgcon)
	e7:SetTarget(s.dmgtg)
	e7:SetOperation(s.dmgop)
	c:RegisterEffect(e7)

	-------------------------------------------------
	-- Dynamic ATK / DEF (NO ACCUMULATION)
	-------------------------------------------------
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_SET_ATTACK)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetValue(s.atkval)
	c:RegisterEffect(e8)

	local e9=e8:Clone()
	e9:SetCode(EFFECT_SET_DEFENSE)
	e9:SetValue(s.defval)
	c:RegisterEffect(e9)
end

-------------------------------------------------
-- Helpers
-------------------------------------------------
-------------------------------------------------
-- Alternative Special Summon helpers
-------------------------------------------------
function s.hspfilter(c,tp,sc)
	return c:IsFaceup()
		and c:IsReleasable()
		and c:IsRace(RACE_AQUA)
		and c:IsAttribute(ATTRIBUTE_WATER)
		and c:GetLevel()==10
		and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end

function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.hspfilter,1,false,1,true,c,tp,nil,nil,nil,tp,c)
end

function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(
		tp,s.hspfilter,1,1,false,true,true,c,tp,nil,false,nil,tp,c
	)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
	g:DeleteGroup()
end

function s.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:GetLevel()==10
end

function s.tglimit(e,c)
	return c~=e:GetHandler()
end

function s.eqfilter(c)
	return c:GetFlagEffect(id)~=0
end

function s.eqcon(e,tp)
	return #e:GetHandler():GetEquipGroup():Filter(s.eqfilter,nil)==0
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingTarget(Card.IsMonster,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsMonster,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.eqop(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp)) then return end
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,id) then return end
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
end

-------------------------------------------------
-- ATK / DEF calculation
-------------------------------------------------
function s.atkval(e,c)
	local g=c:GetEquipGroup():Filter(Card.GetFlagEffect,nil,id)
	if #g==0 then return 3000 end
	return 3000 + math.max(g:GetFirst():GetAttack(),0)
end

function s.defval(e,c)
	local g=c:GetEquipGroup():Filter(Card.GetFlagEffect,nil,id)
	if #g==0 then return 3000 end
	return 3000 + math.max(g:GetFirst():GetDefense(),0)
end

-------------------------------------------------
-- Damage effect
-------------------------------------------------
function s.dmgcon(e,tp)
	return e:GetHandler():GetEquipGroup():IsExists(Card.GetFlagEffect,1,nil,id)
end

function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

function s.dmgop(e,tp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(Card.GetFlagEffect,nil,id)
	if #g==0 then return end
	local tc=g:GetFirst()
	local atk=math.max(tc:GetBaseAttack(),0)
	if Duel.Destroy(tc,REASON_EFFECT)>0 and atk>0 then
		Duel.Damage(1-tp,math.floor(atk/2),REASON_EFFECT)
	end
end
