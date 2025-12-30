--Unholy Synchronicity of the Wicked
local s,id=GetID()

function s.initial_effect(c)
	--------------------------------
	-- Activate (normal activation)
	--------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--------------------------------
	-- Cannot be destroyed by card effects
	-- while you control any "The Wicked" monster
	--------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	--------------------------------
	-- Avatar & Eraser unaffected by Dreadroot's effects
	--------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.immtg1)
	e2:SetValue(s.immval1)
	c:RegisterEffect(e2)

	--------------------------------
	-- Avatar & Dreadroot unaffected by Eraser's effects
	--------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.immtg2)
	e3:SetValue(s.immval2)
	c:RegisterEffect(e3)

	--------------------------------
	-- If sent to GY: add "Blasphemous Ascension"
	--------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)

	--------------------------------
	-- You can only control 1
	--------------------------------
	c:SetUniqueOnField(1,0,id)
end

--------------------------------
-- Listed names
--------------------------------
s.listed_names={
	21208154, -- The Wicked Avatar
	62180201, -- The Wicked Dreadroot
	57793869, -- The Wicked Eraser
	-- Blasphemous Ascension (añade el ID si quieres listarlo)
}

--------------------------------
-- Indestructible condition
--------------------------------
function s.indfilter(c)
	return c:IsFaceup() and c:IsCode(21208154,62180201,57793869)
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(
		s.indfilter,
		e:GetHandlerPlayer(),
		LOCATION_MZONE,0,1,nil
	)
end

--------------------------------
-- (1) Avatar & Eraser unaffected by Dreadroot
--------------------------------
function s.immtg1(e,c)
	return c:IsFaceup() and c:IsCode(21208154,57793869)
end
function s.immval1(e,te)
	local tc=te:GetHandler()
	return te:IsActiveType(TYPE_MONSTER)
		and tc:IsControler(e:GetHandlerPlayer())
		and tc:IsCode(62180201) -- Dreadroot
end

--------------------------------
-- (2) Avatar & Dreadroot unaffected by Eraser
--------------------------------
function s.immtg2(e,c)
	return c:IsFaceup() and c:IsCode(21208154,62180201)
end
function s.immval2(e,te)
	local tc=te:GetHandler()
	return te:IsActiveType(TYPE_MONSTER)
		and tc:IsControler(e:GetHandlerPlayer())
		and tc:IsCode(57793869) -- Eraser
end

--------------------------------
-- Search Blasphemous Ascension
--------------------------------
function s.thfilter(c)
	return c:IsCode(1000000066) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil
		)
	end
	Duel.SetOperationInfo(
		0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE
	)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(
		tp,
		aux.NecroValleyFilter(s.thfilter),
		tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil
	)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
