--Inevitable End
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_names={57793869} -- The Wicked Eraser

-- Condition: control Eraser
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
		and re:IsActiveType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(s.eraserfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.eraserfilter(c)
	return c:IsFaceup() and c:IsCode(57793869)
end

-- Target: negate + destroy + remove all copies
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsChainNegatable(ev) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,
		LOCATION_GRAVE+LOCATION_DECK)
end

-- Operation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if not tc then return end

	local code=tc:GetOriginalCode() -- Guardamos el código antes de destruir

	-- Negar activación
	if Duel.NegateActivation(ev) then
		-- Destruir el monstruo activado si aún está en el campo
		if tc:IsRelateToEffect(re) and tc:IsDestructable() then
			Duel.Destroy(tc,REASON_EFFECT)
		end

		-- Buscar TODAS las copias en mano, Deck, GY, campo y banished
		local g=Duel.GetMatchingGroup(function(c)
			return c:IsOriginalCode(code)
		end, 1-tp,
			LOCATION_GRAVE+LOCATION_DECK,
			0,nil)

		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
