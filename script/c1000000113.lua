--Slifer, the Protector Dragon of the Sky (MIKE CUSTOM FINAL)
local s,id=GetID()
function s.initial_effect(c)
	--Must be Special Summoned (from your Extra Deck) by sending the above cards from your hand and/or field to your GY
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.spcon)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)

	--Special Summon cannot be negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)

	--When Special Summoned: cards and effects cannot be activated
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.sumsuc)
	c:RegisterEffect(e2)

	--Opponent cannot Tribute, target this card by effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_RELEASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,1)
	e3:SetTarget(function(e,c) return c==e:GetHandler() end)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)

	--Unaffected by non-DIVINE monsters
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetValue(s.immval)
	c:RegisterEffect(e6)

	--Gains 1000 ATK/DEF per card in your hand
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SET_BASE_ATTACK)
	e7:SetValue(s.adval)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e8)

	--Thunder Bullet effect (same as anime Slifer)
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,0))
	e9:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DESTROY)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e9:SetCode(EVENT_SUMMON_SUCCESS)
	e9:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCondition(s.atkcon)
	e9:SetTarget(s.atktg)
	e9:SetOperation(s.atkop)
	c:RegisterEffect(e9)
	local e10=e9:Clone()
	e10:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e10)
	local e11=e9:Clone()
	e11:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e11)

	--When leaves field: Special Summon Slifer or add Divine Evolution
	local e12=Effect.CreateEffect(c)
	e12:SetDescription(aux.Stringid(id,1))
	e12:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e12:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e12:SetCode(EVENT_LEAVE_FIELD)
	e12:SetProperty(EFFECT_FLAG_DELAY)
	e12:SetCountLimit(1,{id,1})
	e12:SetTarget(s.lftg)
	e12:SetOperation(s.lfop)
	c:RegisterEffect(e12)
end

------------------------------------------------------------
-- Material filters (Slifer + Divine Evolution)
function s.spfilter1(c)
	return c:IsCode(10000020) and c:IsAbleToGraveAsCost()
end
function s.spfilter2(c)
	return c:IsCode(7373632) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local slf=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local evo=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	local g=Group.FromCards(slf,evo)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end

------------------------------------------------------------
-- Prevent activation when summoned
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end

------------------------------------------------------------
-- Gains ATK/DEF
function s.adval(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000
end

------------------------------------------------------------
-- Thunder Bullet effect (anime version)
function s.atkfilter(c,p,e)
	return c:IsControler(p) and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.atkfilter(chkc,1-tp,e) end
	if chk==0 then return eg:IsExists(s.atkfilter,1,nil,1-tp,e) end
	Duel.SetTargetCard(eg:Filter(s.atkfilter,nil,1-tp,e))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	if #g==0 then return end
	local dg=Group.CreateGroup()
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-2000)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if tc:GetAttack()==0 then dg:AddCard(tc) end
		elseif tc:IsPosition(POS_FACEUP_DEFENSE) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_DEFENSE)
			e1:SetValue(-2000)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if tc:GetDefense()==0 then dg:AddCard(tc) end
		end
	end
	if #dg>0 then
		Duel.BreakEffect()
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

------------------------------------------------------------
-- When leaves field: revive Slifer or add Divine Evolution
function s.revfilter(c,e,tp)
	return c:IsCode(10000020) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.evofilter(c)
	return c:IsCode(7373632) and c:IsAbleToHand()
end
function s.lftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and (Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			or Duel.IsExistingMatchingCard(s.evofilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil))
	end
end
function s.lfop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.evofilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		op=0
	elseif b2 then
		op=1
	else return end

	if op==0 then
		local tc=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TO_GRAVE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	else
		local tc=Duel.SelectMatchingCard(tp,s.evofilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
		if tc then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end

------------------------------------------------------------
-- Unaffected by non-DIVINE monsters
function s.immval(e,te,c)
    local tc=te:GetOwner()
    -- Inmune a efectos de monstruos de otros excepto DIVINE
    if te:IsMonsterEffect() and c~=tc and not tc:IsAttribute(ATTRIBUTE_DIVINE) then
        return true
    end
    -- No puede ser destruida por Spell/Trap del oponente
    if te:IsSpellTrapEffect() then
        local ex, tg, cat = Duel.GetOperationInfo(0, CATEGORY_DESTROY)
        if ex and tg and tg:IsContains(c) then
            return true
        end
    end
    return false
end