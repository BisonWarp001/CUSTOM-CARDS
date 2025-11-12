--Solar the Sun Priestess
local s,id=GetID()
function s.initial_effect(c)

-- Listados (para búsquedas y compatibilidad)
s.listed_names={10000000,10000020,10000010} -- Obelisk, Slifer, Ra
s.listed_series={}

    ---------------------------------------
    -- ① SS from hand only (Quick Effect)
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
    -- ② On Summon: Optional SS Azure / Crimson
    ---------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.sumtg)
    e2:SetOperation(s.sumop)
    c:RegisterEffect(e2)
    local e2b=e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)

    ---------------------------------------
    -- ③ Protection if Tributed for Obelisk / Slifer / Ra
    ---------------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.immcon)
    e3:SetOperation(s.immop)
    c:RegisterEffect(e3)

end

---------------------------------------
-- ① SS from hand only
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
        -- Cannot Special Summon from Extra Deck this turn
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
        e1:SetTargetRange(1,0)
        e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

---------------------------------------
-- IDs of Azure / Crimson
---------------------------------------
local AZURE_ID   = 1000000127
local CRIMSON_ID = 1000000128

---------------------------------------
-- IDs of the Egyptian Gods
---------------------------------------
local OBELISK_ID = 10000000
local SLIFER_ID  = 10000020
local RA_ID      = 10000010

---------------------------------------
-- ② Target check
---------------------------------------
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        if ft<=0 then return false end

        local canAzure = Duel.IsExistingMatchingCard(function(c) 
            return c:IsCode(AZURE_ID) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        end,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)

        local canCrimson = Duel.IsExistingMatchingCard(function(c)
            return c:IsCode(CRIMSON_ID) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        end,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)

        return canAzure or canCrimson
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

---------------------------------------
-- ② Operation: Choose Azure/Crimson
---------------------------------------
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    local toSummon=Group.CreateGroup()

    -- Ask for Azure
    if ft>#toSummon and Duel.IsExistingMatchingCard(function(c)
        return c:IsCode(AZURE_ID) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) then

        if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            local g1=Duel.SelectMatchingCard(tp,function(c)
                return c:IsCode(AZURE_ID) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
            end,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
            toSummon:Merge(g1)
        end
    end

    -- Ask for Crimson
    if ft>#toSummon and Duel.IsExistingMatchingCard(function(c)
        return c:IsCode(CRIMSON_ID) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) then

        if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            local g2=Duel.SelectMatchingCard(tp,function(c)
                return c:IsCode(CRIMSON_ID) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
            end,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
            toSummon:Merge(g2)
        end
    end

    if #toSummon>0 then
        Duel.SpecialSummon(toSummon,0,tp,tp,false,false,POS_FACEUP)
    end
end

---------------------------------------
-- ③ Protection for Gods
---------------------------------------
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
    return (r&REASON_SUMMON)==REASON_SUMMON or (r&REASON_RELEASE)==REASON_RELEASE
end

function s.immop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    if not rc then return end

    -- Only for Egyptian Gods
    if not rc:IsCode(OBELISK_ID,SLIFER_ID,RA_ID) then return end

    -- Immunity to ACTIVATED monster effects from opponent (except DIVINE)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(function(e,te)
        return te:IsActiveType(TYPE_MONSTER)
            and te:IsActivated()
            and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
            and not te:GetHandler():IsAttribute(ATTRIBUTE_DIVINE)
    end)
    rc:RegisterEffect(e1)
end
