--Orichalcos Fusion Ritual
local s,id=GetID()

function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({
		handler=c,
		fusfilter=s.fusfilter,
		matfilter=s.matfilter,
		extrafil=s.extrafil,
		extraop=Fusion.ShuffleMaterial,
		stage2=s.desop,
		extratg=s.extratg
	})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	c:RegisterEffect(e1)
end

-------------------------------------------------
-- Fusion Monster filter
-- Only "Orichalcos" Fusion Monsters
-------------------------------------------------
function s.fusfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x3e8)
end

-------------------------------------------------
-- Material filter
-- Only "Orichalcos" monsters
-------------------------------------------------
function s.matfilter(c)
	return c:IsMonster() and c:IsSetCard(0x3e8) and c:IsAbleToDeck()
end

-------------------------------------------------
-- Extra materials from GY
-------------------------------------------------
function s.extrafil(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(
		aux.NecroValleyFilter(s.matfilter),
		tp,
		LOCATION_GRAVE,
		0,
		nil
	)
end

-------------------------------------------------
-- Count Orichalcos monsters used FROM FIELD
-------------------------------------------------
function s.field_filter(c,tp)
	return c:IsSetCard(0x3e8)
		and c:IsPreviousLocation(LOCATION_MZONE)
		and c:GetPreviousControler()==tp
end

-------------------------------------------------
-- Destroy operation (Stage 2)
-------------------------------------------------
function s.desop(e,tc,tp,mg,chk)
	if chk~=0 then return end

	local ct=mg:FilterCount(s.field_filter,nil,tp)
	if ct==0 then return end

	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	if #g==0 then return end

	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,ct,nil)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end

-------------------------------------------------
-- Target info
-------------------------------------------------
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(
		0,
		CATEGORY_TODECK,
		nil,
		0,
		tp,
		LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE
	)
	Duel.SetPossibleOperationInfo(
		0,
		CATEGORY_DESTROY,
		nil,
		0,
		1-tp,
		LOCATION_ONFIELD
	)
end
