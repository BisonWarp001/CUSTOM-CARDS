--Hassan, Sacred Servant of the Pharaoh
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon: 1 Level 10 monster
	Link.AddProcedure(c,s.matfilter,1,1)

	--① Banish and Special Summon "Sacred Servant" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--② Tribute itself to search "Divine-Beast" or card that lists them
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

--Arquetipo Sacred Servant
s.listed_series={0x410}

--Material del Link
function s.matfilter(c,scard,sumtype,tp)
	return c:IsLevel(10)
end

---------------------------------------
-- EFECTO 1
---------------------------------------

--Condición: que haya sido Invocado por Enlace
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinkSummoned()
end

--Filtro para remover (solo monstruos)
function s.rmfilter(c)
	return c:IsMonster() and c:IsAbleToRemove()
end

--Filtro de Invocación Especial
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x410)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

--Check de selección (que existan suficientes monstruos a invocar)
function s.spcheck(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg,tp,LOCATION_REASON_TOFIELD)>=#sg
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,#sg,nil,e,tp)
end

--Target del efecto 1
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,1,3,s.spcheck,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

--Operación del efecto 1
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)

	local ct=3
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		ct=1
	end

	--Selecciona 1-3 monstruos para remover
	local rg=aux.SelectUnselectGroup(g,e,tp,1,ct,s.spcheck,1,tp,HINTMSG_REMOVE)
	if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
		--Cantidad de cartas realmente removidas
		local removed=#Duel.GetOperatedGroup()
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)

		removed=math.min(removed,ft)

		if removed<=0 then return end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,removed,removed,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end

	--Restricción: solo DIVINE este turno
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)

	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetReset(RESET_PHASE|PHASE_END)
	e4:SetTargetRange(1,0)
	Duel.RegisterEffect(e4,tp)
end

function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DIVINE)
end

---------------------------------------
-- EFECTO 2
---------------------------------------

--Coste: Sacrificar esta carta
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

--Filtro de búsqueda
function s.thfilter(c)
	--Monstruos Divine-Beast
	if c:IsRace(RACE_DIVINE) and c:IsAbleToHand() then
		return true
	end
	--Spell/Trap que mencionen a Egyption Gods
	if c:IsType(TYPE_SPELL+TYPE_TRAP)
	and (c:ListsCode(10000000) or c:ListsCode(10000020) or c:ListsCode(10000010))
	and c:IsAbleToHand() then
		return true
	end
	return false
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
