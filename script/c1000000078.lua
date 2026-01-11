--Sphinx Roar
local s,id=GetID()

function s.initial_effect(c)
	--Activate: Special Summon Andro Sphinx + Sphinx Teleia
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--GY: Banish this card (except turn sent); destroy Andro + Teleia, gain LP
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.gycon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
end

--Card IDs
local ANDRO=15013468
local TELEIA=51402177

--=====================
-- Special Summon both
--=====================
function s.spfilter(c,e,tp)
	return c:IsCode(ANDRO,TELEIA)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,2,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND|LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	if not (g:IsExists(Card.IsCode,1,nil,ANDRO) and g:IsExists(Card.IsCode,1,nil,TELEIA)) then return end

	local sg=Group.CreateGroup()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=g:Filter(Card.IsCode,nil,ANDRO)
	sg:AddCard(g1:Select(tp,1,1,nil):GetFirst())
	local g2=g:Filter(Card.IsCode,nil,TELEIA)
	sg:AddCard(g2:Select(tp,1,1,nil):GetFirst())

	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end

--=====================
-- GY effect condition
--=====================
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetHandler():GetTurnID()
end

--=====================
-- Destroy both → gain LP
--=====================
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,ANDRO),tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,TELEIA),tp,LOCATION_MZONE,0,1,nil)
	end
end

function s.recop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,
		aux.FaceupFilter(Card.IsCode,ANDRO),
		tp,LOCATION_MZONE,0,1,1,nil)
	if #g1==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectMatchingCard(tp,
		aux.FaceupFilter(Card.IsCode,TELEIA),
		tp,LOCATION_MZONE,0,1,1,nil)
	if #g2==0 then return end

	local c1=g1:GetFirst()
	local c2=g2:GetFirst()
	local atk=c1:GetAttack()+c2:GetAttack()

	if Duel.Destroy(Group.FromCards(c1,c2),REASON_EFFECT)==2 then
		Duel.Recover(tp,atk,REASON_EFFECT)
	end
end
