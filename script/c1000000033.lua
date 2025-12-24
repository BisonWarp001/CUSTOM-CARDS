--Brynhildr, Valkyria of the Aesir
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x42),1,1,Synchro.NonTuner(nil),1,99)

	--① When Synchro Summoned: Set 1 "Nordic Relic" Spell/Trap from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)

	--② Tribute self + up to 2 monsters, total Levels = 10; Special Summon 1 Level 10 "Aesir" Synchro from Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	--③ End Phase: banish this card from GY; Special Summon 1 Level 10 "Aesir" from GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.revcon)
	e3:SetTarget(s.revtg)
	e3:SetOperation(s.revop)
	c:RegisterEffect(e3)
end

--① Set 1 "Nordic Relic" Spell/Trap
--① When Synchro Summoned: Set 1 "Nordic Relic" Spell/Trap from Deck
function s.setfilter(c)
	return c:IsSetCard(0x42) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
		Duel.ConfirmCards(1-tp,g)
	end
end

--② Tribute monsters with total Levels = 10 to summon Level 10 "Aesir"
function s.relfilter(c)
	return c:IsFaceup() and c:IsReleasable() and c:GetLevel()>0
end
function s.aesirfilter(c,e,tp)
	return IsAesir(c) and c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCountFromEx(tp,tp,c)>0
			and Duel.IsExistingMatchingCard(s.aesirfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	local g=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=aux.SelectUnselectGroup(g,e,tp,1,2,
		function(sg,e,tp,mg) return sg:GetSum(Card.GetLevel)==10 end,1,tp,HINTMSG_RELEASE)
	if #rg==0 then return end
	rg:AddCard(c)
	Duel.Release(rg,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.aesirfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local sc=sg:GetFirst()
	if sc then
		Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end

--③ End Phase revival
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(IsAesir,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    -- Seleccionar Level 10 Aesir en el GY que NO sea esta carta
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,function(tc)
        return IsAesir(tc) and tc:IsLevel(10) and tc~=c and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end,tp,LOCATION_GRAVE,0,1,1,nil)

    local tc=g:GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        -- Finalmente remover esta carta del GY
        Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
    end
end
