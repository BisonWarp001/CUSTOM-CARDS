--Azure the Colossus Priestess
local s,id=GetID()

-- Listados (para búsquedas y compatibilidad)
s.listed_names={10000000,10000020,10000010}
s.listed_series={}

-- IDs de los Dioses Egipcios
local OBELISK_ID = 10000000
local SLIFER_ID  = 10000020
local RA_ID      = 10000010

function s.initial_effect(c)

	---------------------------------------
	-- ① Quick Effect: SS desde mano o GY
	---------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	---------------------------------------
	-- ② On Summon: Buscar Obelisk / Slifer / Ra o carta que los mencione
	---------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)

	---------------------------------------
	-- ③ Si es tributada para Obelisk/Slifer/Ra → inmunidad a S/T activadas
	---------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.immcon)
	e3:SetOperation(s.immop)
	c:RegisterEffect(e3)

end

---------------------------------------
-- ① SS desde mano
---------------------------------------
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- No Extra Deck SS este turno
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

---------------------------------------
-- ② Buscar dios egipcio o carta que lo mencione
---------------------------------------
function s.thfilter(c)
	return (
		c:IsCode(OBELISK_ID) or
		c:IsCode(SLIFER_ID) or
		c:IsCode(RA_ID) or
		Card.ListsCode(c,OBELISK_ID) or
		Card.ListsCode(c,SLIFER_ID) or
		Card.ListsCode(c,RA_ID)
		)
		and not c:IsCode(id)
		and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

---------------------------------------
-- ③ Protección al Dios Egipcio (solo si fue tributada para él)
---------------------------------------
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SUMMON or r==REASON_RELEASE
end

function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if not rc then return end

	-- Debe ser uno de los 3 dioses
	if not rc:IsCode(OBELISK_ID,SLIFER_ID,RA_ID) then return end

	-- Inmunidad a S/T activadas del oponente
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(function(e,te)
		return te:IsActivated()
			and te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
			and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
	end)
	rc:RegisterEffect(e1)
end
