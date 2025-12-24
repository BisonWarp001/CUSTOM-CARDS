--Egyptian God Eternal Slime
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA),s.matfilter)

		--This card's name becomes "Egyptian God Slime " while on the field
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(42166000) 
	c:RegisterEffect(e0)
	--special summon (tribute materials)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)

	--triple tribute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRIPLE_TRIBUTE)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	-- Opponent's monsters cannot select your other monsters as attack targets
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	-- opponent's monsters (they choose targets on their side)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atktg)
	c:RegisterEffect(e2)

	-- Opponent cannot target your other monsters with card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	-- apply to your monsters
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.tgtg)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)

	--equip opponent monster (once per turn, Quick Effect)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.eqcon)
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)

	--ER Equip limit
	aux.AddEREquipLimit(
		c,
		s.eqcon,
		function(ec,_,tp) return ec:IsControler(1-tp) end,
		s.equipop,
		e4
	)

	--destroy replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.reptg)
	e5:SetOperation(s.repop)
	c:RegisterEffect(e5)

	---------------------------------------------
	-- 💧 NEW EFFECT: If sent to GY → SS 1 WATER
	---------------------------------------------
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(s.spcon_gy)
	e6:SetTarget(s.sptg_gy)
	e6:SetOperation(s.spop_gy)
	c:RegisterEffect(e6)
end

-------------------------------------------------
-- FUSION MATERIAL
-------------------------------------------------
function s.matfilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WATER,fc,sumtype,tp) and c:IsLevel(10)
end

-- attack target limiter: opponent cannot select monsters except this card
function s.atktg(e,c)
	return c~=e:GetHandler()
end

-- effect target limiter: your other monsters cannot be targeted by opponent's effects
function s.tgtg(e,c)
	return c~=e:GetHandler()
end
-------------------------------------------------
-- SPECIAL SUMMON PROCEDURE
-------------------------------------------------
function s.hspfilter_both(c,tp,sc)
	return c:IsFaceup() and c:IsReleasable()
		and c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevel(10)
		and c:IsRace(RACE_AQUA)
		and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.hspfilter_water10(c,tp,sc)
	return c:IsFaceup() and c:IsReleasable()
		and c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevel(10)
		and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.hspfilter_aqua(c)
	return c:IsFaceup() and c:IsReleasable() and c:IsRace(RACE_AQUA)
end

function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.IsExistingMatchingCard(s.hspfilter_both,tp,LOCATION_MZONE,0,1,nil,tp,c) then
		return true
	end
	return Duel.IsExistingMatchingCard(s.hspfilter_water10,tp,LOCATION_MZONE,0,1,nil,tp,c)
		and Duel.IsExistingMatchingCard(s.hspfilter_aqua,tp,LOCATION_MZONE,0,1,nil)
end

function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectMatchingCard(tp,s.hspfilter_both,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	local g1=Duel.SelectMatchingCard(tp,s.hspfilter_water10,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
	local g2=Duel.SelectMatchingCard(tp,s.hspfilter_aqua,tp,LOCATION_MZONE,0,1,1,g1:GetFirst())
	g1:Merge(g2)
	g1:KeepAlive()
	e:SetLabelObject(g1)
	return true
end

function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g then
		Duel.Release(g,REASON_COST|REASON_MATERIAL)
		g:DeleteGroup()
	end
end

-------------------------------------------------
-- EQUIP SYSTEM
-------------------------------------------------
function s.eqfilter(c)
	return c:GetFlagEffect(id)~=0
end

function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(s.eqfilter,nil)
	return #g==0
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Card.IsMonster,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,Card.IsMonster,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and s.eqcon(e,tp,eg,ep,ev,re,r,rp) then
		s.equipop(c,e,tp,tc)
	end
end

function s.equipop(c,e,tp,tc)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,id) then return end
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
end

-------------------------------------------------
-- DESTRUCTION REPLACEMENT (CORRECTO)
-------------------------------------------------
function s.repfilter(c)
	return c:GetFlagEffect(id)~=0 and c:IsAbleToGrave()
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then 
		return c:IsOnField() and c:IsReason(REASON_BATTLE+REASON_EFFECT)
			and c:GetEquipGroup():IsExists(s.repfilter,1,nil)
	end
	return Duel.SelectYesNo(tp,aux.Stringid(id,1))
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(s.repfilter,nil)
	if #g>0 then
		Duel.SendtoGrave(g:GetFirst(),REASON_EFFECT+REASON_REPLACE)
	end
end

-------------------------------------------------
-- 💧 EFFECT: If sent to GY → Special Summon 1 WATER
-------------------------------------------------
function s.spcon_gy(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT+REASON_BATTLE)
end

function s.sptg_gy(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter_gy,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spfilter_gy(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsCode(id) -- 🔥 evita auto-invocación
end

function s.spop_gy(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter_gy,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
