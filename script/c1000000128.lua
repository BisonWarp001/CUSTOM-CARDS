--Crimson the Sky Priestess
local s,id=GetID()
s.listed_names={10000000,10000020,10000010} -- Obelisk, Slifer, Ra

function s.initial_effect(c)
	----------------------------------------------------------------------
	-- ① Special Summon from hand (Quick)
	----------------------------------------------------------------------
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

	----------------------------------------------------------------------
	-- ② Extra Tribute Summon + Quick Tribute Summon for DIVINE
	----------------------------------------------------------------------
	-- (a) Extra Tribute Summon for Obelisk / Slifer / Ra
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.grant_extra_summon)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)

	-- (b) Quick Tribute Summon for DIVINE during opponent’s Main/Battle Phase
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_END)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.quick_nscon)
	e3:SetTarget(s.quick_nstg)
	e3:SetOperation(s.quick_nsop)
	c:RegisterEffect(e3)

	----------------------------------------------------------------------
	-- ③ If Tributed for Obelisk/Slifer/Ra → opponent cannot Tribute/use as material
	----------------------------------------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCondition(s.matcon)
	e4:SetOperation(s.matop)
	c:RegisterEffect(e4)
end

----------------------------------------------------------------------
-- (1) Special Summon from hand 
----------------------------------------------------------------------
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Restrict Extra Deck SS for the rest of this turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetTargetRange(1,0)
	e0:SetTarget(function(_,sc) return sc:IsLocation(LOCATION_EXTRA) end)
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)

	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

----------------------------------------------------------------------
-- (2a) Extra Tribute Summon for the Gods (one-time per turn)
----------------------------------------------------------------------
local GODS={10000000,10000020,10000010}
function s.grant_extra_summon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)==0 then
		local c=e:GetHandler()
		local ge1=Effect.CreateEffect(c)
		ge1:SetDescription(aux.Stringid(id,3))
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		ge1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		ge1:SetTarget(function(_,tc) return tc:IsCode(table.unpack(GODS)) end)
		ge1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(ge1,tp)
		local ge2=ge1:Clone()
		ge2:SetCode(EFFECT_EXTRA_SET_COUNT)
		Duel.RegisterEffect(ge2,tp)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end

----------------------------------------------------------------------
-- (2b) Quick Tribute Summon for DIVINE monsters (opponent’s turn)
----------------------------------------------------------------------
function s.quick_nscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and (Duel.IsMainPhase() or Duel.IsBattlePhase())
end
function s.quick_nsfilter(c)
	return c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsSummonable(true,nil)
end
function s.quick_nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.quick_nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.quick_nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.quick_nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end

----------------------------------------------------------------------
-- (3) Protection: opponent cannot Tribute or use as material
----------------------------------------------------------------------
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return (r & REASON_SUMMON) == REASON_SUMMON or (r & REASON_RELEASE) == REASON_RELEASE
end

function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if not rc or not rc:IsCode(10000000,10000020,10000010) then return end

	-- Only restrict the opponent
	local opp=1-tp

	-- Opponent cannot Tribute that monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1) -- applies only to opponent
	e1:SetTarget(function(e,tc) return tc==e:GetLabelObject() end)
	e1:SetValue(1)
	e1:SetLabelObject(rc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	Duel.RegisterEffect(e1,tp)

	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	Duel.RegisterEffect(e1b,tp)

	-- Opponent cannot use that monster as material for any type of Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetTarget(function(e,tc) return tc==e:GetLabelObject() end)
	e2:SetValue(1)
	e2:SetLabelObject(rc)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	Duel.RegisterEffect(e2,tp)
end
