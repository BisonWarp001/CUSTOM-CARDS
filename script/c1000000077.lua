--The Broken Pyramid
local s,id=GetID()

function s.initial_effect(c)
	--Activate (Quick-Play)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end

--Card IDs
local PYRAMID=53569894
local ANDRO=15013468
local TELEIA=51402177

--=====================
-- Target Pyramid of Light
--=====================
function s.desfilter(c)
	return c:IsFaceup()
		and c:IsCode(PYRAMID)
		and c:IsDestructable()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
end

--=====================
-- Destroy → snapshot Andro / Teleia → draw
--=====================
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end

	-- Snapshot BEFORE destruction
	local ct=0
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,ANDRO),tp,LOCATION_MZONE,0,1,nil) then
		ct=ct+1
	end
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,TELEIA),tp,LOCATION_MZONE,0,1,nil) then
		ct=ct+1
	end

	if Duel.Destroy(tc,REASON_EFFECT)==0 then return end

	if ct>0 and Duel.IsPlayerCanDraw(tp,ct) then
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end
