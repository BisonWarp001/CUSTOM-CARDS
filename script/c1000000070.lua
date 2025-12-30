--Profane Altar
local s,id=GetID()

function s.initial_effect(c)
	--Activation (no effect)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Effect 1: Once per turn, add or send to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	--Effect 2: Banish from GY; Set 1 Spell/Trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

s.listed_names={21208154,62180201,57793869}
-- The Wicked Avatar, The Wicked Dreadroot, The Wicked Eraser

-------------------------------------------------
-- Filters
-------------------------------------------------
function s.altarfilter(c)
	return c:IsSpellTrap()
		and c:ListsCode(21208154,62180201,57793869)
end

-------------------------------------------------
-- Effect 1: Add or send to GY
-------------------------------------------------
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.altarfilter,tp,LOCATION_DECK,0,1,nil)
	end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(tp,s.altarfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	local tc=g:GetFirst()

	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	else
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end

-------------------------------------------------
-- Effect 2: Set Spell/Trap from Deck or GY
-------------------------------------------------
function s.setfilter(c)
	return c:IsSpellTrap()
		and c:ListsCode(21208154,62180201,57793869)
		and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil
		)
	end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(
		tp,s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil
	)
	if #g==0 then return end
	Duel.SSet(tp,g:GetFirst())
end
