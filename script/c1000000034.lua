--Sleipnir, Nordic Steed of the Aesir
local s,id=GetID()

-- 🔹 Cargar utilidades globales de Mike (solo si no están ya cargadas)
if not MIKE_IMPORTED then
    Duel.LoadScript("MIKECUSTOM_GLOBAL.lua")
end

-- Marcar como cargado para no duplicar
MIKE_IMPORTED = true

s.listed_series={0x42,0x4b} -- Nordic & Aesir

--------------------------------
-- Inicialización
--------------------------------
function s.initial_effect(c)
	-- Link Summon: 2 Effect Monsters, incluyendo al menos 1 "Nordic"
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2,s.lcheck)

	--① Banish 1 card from hand or GY: Send 1 "Nordic" monster from Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)

	--② During opponent's turn: Tribute this card → Special + Synchro Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.spcon2)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end

--------------------------------
-- 🔹 Link Summon requirement
--------------------------------
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(IsNordic,1,nil)
end

--------------------------------
-- 🔹 Effect ①
--------------------------------
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(IsNordic,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,function(c) return IsNordic(c) and c:IsType(TYPE_MONSTER) end,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end


--------------------------------
-- 🔹 Effect ②
--------------------------------
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(function(c) return IsNordic(c) and not c:IsType(TYPE_LINK) end,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(function(c) return IsAesir(c) and c:IsType(TYPE_SYNCHRO) end,tp,LOCATION_EXTRA,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,function(c) return IsNordic(c) and not c:IsType(TYPE_LINK) end,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

	-- Obtener todos los monstruos de tu lado del campo
	local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE,0,nil)

	-- Filtrar Synchro monsters que se pueden invocar con los materiales disponibles
	local sg=Duel.GetMatchingGroup(function(c)
		return IsAesir(c) and c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil)
	end,tp,LOCATION_EXTRA,0,nil)

	if #sg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	Duel.SynchroSummon(tp,sc,nil)
end
