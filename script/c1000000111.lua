--Obelisk, the Titan Tormentor (MIKE CUSTOM)
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
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(s.immval)
	c:RegisterEffect(e6)

	--Quick Effect: Tribute 2 monsters; destroy all opponent monsters, inflict damage if not all destroyed
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,id)
	e7:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e7:SetCost(s.descost)
	e7:SetTarget(s.destg)
	e7:SetOperation(s.desop)
	c:RegisterEffect(e7)

	--When leaves field: Special Summon Obelisk or add Divine Evolution
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,1))
	e8:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_LEAVE_FIELD)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCountLimit(1,{id,1})
	e8:SetTarget(s.lftg)
	e8:SetOperation(s.lfop)
	c:RegisterEffect(e8)
end

------------------------------------------------------------
-- Material filters (Obelisk + Divine Evolution)
function s.spfilter1(c)
	return c:IsCode(10000000) and c:IsAbleToGraveAsCost()
end
function s.spfilter2(c)
	return c:IsCode(7373632) and c:IsAbleToGraveAsCost()
end

-- Summon condition (hand or field)
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
end

-- Summon operation (send to GY)
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local ob=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local evo=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	local g=Group.FromCards(ob,evo)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end

------------------------------------------------------------
-- Prevent activation when summoned
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end

------------------------------------------------------------
-- Tribute 2 to destroy + damage
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then 
		return Duel.CheckReleaseGroupCost(tp,aux.TRUE,2,false,nil,c)
	end
	local g=Duel.SelectReleaseGroupCost(tp,aux.TRUE,2,2,false,nil,c)
	Duel.Release(g,REASON_COST)
	--Cannot attack this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetHandler():GetAttack())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct<#g then
		Duel.Damage(1-tp,c:GetAttack(),REASON_EFFECT)
	end
end

------------------------------------------------------------
-- When leaves field: revive Obelisk or add Divine Evolution
function s.revfilter(c,e,tp)
	return c:IsCode(10000000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.evofilter(c)
	return c:IsCode(7373632) and (c:IsAbleToHand() or c:IsAbleToGrave())
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
		if tc then Duel.SendtoHand(tc,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,tc) end
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