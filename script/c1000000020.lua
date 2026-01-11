local s,id=GetID()
local TOKEN_SLIME=1000000021

function s.initial_effect(c)

	------------------------------------------------
	-- 1) If added to hand except by drawing: SS
	------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	------------------------------------------------
	-- 2) Lose ATK in multiples of 1000 → Tokens
	------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.tkcon)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)

	------------------------------------------------
	-- 3) If sent to the GY → Search Obelisk S/T
	------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+200)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

------------------------------------------------
-- EFFECT 1
------------------------------------------------
function s.spcon(e)
	return not e:GetHandler():IsReason(REASON_DRAW)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end

function s.spop(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

------------------------------------------------
-- EFFECT 2
------------------------------------------------
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttack()>=1000
end

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	local ct=math.floor(atk/1000)
	if chk==0 then
		return ct>0
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>=1
			and Duel.IsPlayerCanSpecialSummonMonster(
				tp,TOKEN_SLIME,0,
				TYPE_TOKEN,500,500,1,
				RACE_AQUA,ATTRIBUTE_WATER
			)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,0)
end

function s.tkop(e,tp)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	if atk<1000 then return end

	local ct=math.floor(atk/1000)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local sel=Duel.AnnounceNumber(tp,table.unpack({1,ct}))
	local lose=sel*1000

	if not (c:IsFaceup() and c:IsRelateToEffect(e) and c:GetAttack()>=lose) then return end

	-- Reduce ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-lose)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<sel then return end

	for i=1,sel do
		local token=Duel.CreateToken(tp,TOKEN_SLIME)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()

	-- Extra Deck restriction
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,c)
		return c:IsLocation(LOCATION_EXTRA)
			and not (c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_WATER))
	end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

------------------------------------------------
-- EFFECT 3
------------------------------------------------
function s.thfilter(c)
	return c:IsSpellTrap()
		and c:IsAbleToHand()
		and c:ListsCode(10000000)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
