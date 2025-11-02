--Gargoyle Slime
--Scripted by Warp
local s,id=GetID()
local SET_SLIME=0x54b
local TOKEN_SLIME_CUSTOM=79387393 -- Token custom registrado en la DB

function s.initial_effect(c)
    --① Special Summon from hand if a monster is Tributed
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_RELEASE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --② Lose ATK to summon Slime Tokens
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.tktg)
    e2:SetOperation(s.tkop)
    c:RegisterEffect(e2)

    --③ If Tributed: Add 1 Spell/Trap that mentions "Obelisk the Tormentor"
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_RELEASE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

--Listar cartas relacionadas
s.listed_names={10000000,42166000,26905245,TOKEN_SLIME_CUSTOM}
s.listed_series={SET_SLIME}

--① Condición de Invocación Especial
function s.cfilter(c)
    return c:IsMonster() or c:GetPreviousTypeOnField()&TYPE_MONSTER==TYPE_MONSTER
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

--② Perder ATK para invocar Slime Tokens
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
            and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SLIME_CUSTOM,SET_SLIME,TYPES_TOKEN,500,500,1,RACE_AQUA,ATTRIBUTE_WATER)
            and c:GetAttack()>=1000
    end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
    local atk=c:GetAttack()
    local max_tokens=math.floor(atk/1000)
    if max_tokens<=0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NUMBER)
    local num=Duel.AnnounceNumber(tp,table.unpack({1,2}))
    if num>max_tokens then num=max_tokens end

    local lose=num*1000
    if c:IsFaceup() then
        c:UpdateAttack(-lose,RESET_EVENT+RESETS_STANDARD_DISABLE)
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<num then num=Duel.GetLocationCount(tp,LOCATION_MZONE) end
        if num<=0 then return end

        for i=1,num do
            local token=Duel.CreateToken(tp,TOKEN_SLIME_CUSTOM)
            Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
        end
        Duel.SpecialSummonComplete()

        --Extra Deck restriction
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsCode(42166000)
end

--③ Buscar Spell/Trap que mencione “Obelisk the Tormentor”
function s.thfilter(c)
    return c:IsSpellTrap() and c:ListsCode(10000000) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
